//
//  Plex.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2023-08-24.
//

import Combine
import LibPlexUnwatched
import SwiftUI

struct Badge {
    var image: NSImage
    var label: String
    var identifier: String
}

struct Media: Codable {
    var Part: [Part]
}

struct Part: Codable {
    var file: String
}

struct SectionsResponse: Codable {
    var MediaContainer: MediaContainer

    struct MediaContainer: Codable {
        var Directory: [Directory]
    }

    struct Directory: Codable {
        var key: String
        var type: MediaType
        var Location: [Location]
    }

    struct Location: Codable {
        var path: String
    }
}

struct AllResponse: Codable {
    struct MediaContainer: Codable {
        var Metadata: [Metadata]
    }

    struct Metadata: Codable {
        var Media: [Media]
        var viewOffset: Int?
        var viewCount: Int?

        var isUnwatched: Bool { viewCount == nil && viewOffset == nil }
        var isPartiallyWatched: Bool { viewOffset != nil && (viewCount ?? 0) < 1 }
        var isWatched: Bool { viewCount ?? 0 >= 1 }
    }

    var MediaContainer: MediaContainer
}

struct ChildrenResponse: Codable {
    struct MediaContainer: Codable {
        var Metadata: [Metadata]
    }

    struct Metadata: Codable {
        var ratingKey: String
        var type: MediaType
        var Media: [Media]?
    }

    var MediaContainer: MediaContainer
}

struct PlexClient {
    var baseUrl: String
    private let headers = ["Accept": "application/json"]

    func sections() async throws -> [SectionsResponse.Directory] {
        return try await fetch(
            path: "/library/sections",
            as: SectionsResponse.self
        ).MediaContainer.Directory
    }

    func all(section: String) async throws -> [AllResponse.Metadata] {
        return try await fetch(
            path: "/library/sections/\(section)/all",
            as: AllResponse.self
        ).MediaContainer.Metadata
    }

    func children(ratingKey: String) async throws -> [ChildrenResponse.Metadata] {
        return try await fetch(
            path: "/library/metadata/\(ratingKey)/children?unwatched=1",
            as: ChildrenResponse.self
        ).MediaContainer.Metadata
    }

    private func fetch<Result>(path: String, as _: Result.Type) async throws -> Result where Result: Decodable {
        let url = URL(string: baseUrl + path)
        var request = URLRequest(url: url!)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        let (data, _) = try await URLSession.shared.data(for: request)

        return try JSONDecoder().decode(Result.self, from: data)
    }
}

enum PlexError: Error {
    case missingRemotePath(String)
}

private let store = UserDefaults(suiteName: "app-group.com.github.jacob-carlborg.PlexUnwatched")

@MainActor
class Plex: ObservableObject {
    @AppStorage("plexPaths", store: store) var paths = PlexPaths()
    @AppStorage("plexServerUrl") var debouncedPlexServerUrl = ""
    @Published var typedPlexServerUrl = ""

    private var client: PlexClient?
    private var _server: String = ""
    private var subscriptions = Set<AnyCancellable>()

    init() {
        setupPlexServerUrlDebounce()
    }

    func setup() async {
        await handleErrors {
            let sections = try await self.sections
            var newPaths = PlexPaths()
            newPaths.reserveCapacity(self.paths.count)

            for path in self.paths {
                await self.didAddPath(path, sections: sections)
                newPaths.append(path)
            }

            self.paths = newPaths
        }
    }

    func addPath(_ path: PlexPath) async {
        await didAddPath(path)
        paths.append(path)
    }

    func didAddPath(_ path: PlexPath, sections: [SectionsResponse.Directory]? = nil) async {
        await handleErrors {
            let secs: [SectionsResponse.Directory] = if sections != nil {
                sections!
            } else {
                try await self.sections
            }

            let directory = try self.directoryForPath(path, sections: secs)
            path.section = directory.key
            path.type = directory.type

            func convertToLocalPath(file: String) -> String {
                let endIndex = file.index(file.startIndex, offsetBy: path.remotePath.count)
                let range = file.startIndex ..< endIndex
                let result = file.replacingOccurrences(of: path.remotePath, with: path.localPath, range: range)
                return result
            }

            func extractFiles(from metadata: [AllResponse.Metadata]) -> Set<URL> {
                Set(metadata
                    .flatMap { $0.Media }
                    .flatMap { $0.Part }
                    .map { $0.file }
                    .filter { $0.hasPrefix(path.remotePath) }
                    .map(convertToLocalPath)
                    .map { URL(fileURLWithPath: $0) }
                )
            }

            func getDirectories(from paths: Set<URL>) -> Set<URL> {
                let directories = paths.map { $0.deletingLastPathComponent() }
                return paths.union(directories)
            }

            let allItems = try await self.client?.all(section: path.section!) ?? []
            let unwatched = allItems.filter { $0.isUnwatched }
            let partiallyWatched = allItems.filter { $0.isPartiallyWatched }

            path.unwatched = extractFiles(from: unwatched)
            path.partiallyWatched = extractFiles(from: partiallyWatched)

            guard path.syncType == .directory else { return }

            path.unwatched = getDirectories(from: path.unwatched)
            path.partiallyWatched = getDirectories(from: path.partiallyWatched)
        }
    }

    func didChangePath(_: PlexPath) {}

    func didRemovePaths(_ pathIds: Set<PlexPath.ID>) {
        paths.removeAll(where: { pathIds.contains($0.id) })
    }

    private var server: String {
        get { _server }
        set {
            _server = newValue
            debouncedPlexServerUrl = _server
            client = PlexClient(baseUrl: _server)
            print("asd")

            Task {
                await handleErrors {
                    await self.setup()
                }
            }
        }
    }

    private var sections: [SectionsResponse.Directory] {
        get async throws {
            return try await client?.sections() ?? []
        }
    }

    private func setupPlexServerUrlDebounce() {
        typedPlexServerUrl = debouncedPlexServerUrl
        $typedPlexServerUrl
            .debounce(for: .seconds(1), scheduler: RunLoop.main)
            .sink(receiveValue: { [weak self] debouncedText in
                self?.server = debouncedText
            }).store(in: &subscriptions)
    }

    private func directoryForPath(_ path: PlexPath, sections: [SectionsResponse.Directory]) throws -> SectionsResponse.Directory {
        if let directory = sections.first(where: { $0.Location.first(where: { $0.path == path.remotePath }) != nil }) {
            return directory
        } else {
            throw PlexError.missingRemotePath(path.remotePath)
        }
    }

    private func handleErrors(operation: String = #function, action: @escaping () async throws -> Void) async {
        do {
            try await action()
        } catch {
            handleError(error, operation: operation)
        }
    }

    private func handleError(_ error: Error, operation: String = #function) {
        NSLog("\(operation) failed: \(error)")
    }

//    private func task(operation: String = #function, action: @escaping () async throws -> Void) {
//        Task {
//            do {
//                try await action()
//            } catch {
//                handleError(error, operation: operation)
//            }
//        }
//    }
}
