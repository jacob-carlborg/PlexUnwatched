//
//  PlexPath.swift
//  LibPlexUnwatched
//
//  Created by Jacob Carlborg on 2023-09-18.
//

import Foundation

public enum MediaType: String, Codable {
    case show
    case season
    case episode
    case movie
    case video
    case artist
}

public enum SyncType: String, Codable, CaseIterable, Identifiable {
    case file, directory
    public var id: Self { self }
}

public typealias PlexPaths = [PlexPath]

public class PlexPath: Codable, CustomStringConvertible, Hashable, Identifiable, ObservableObject {
    enum CodingKeys: CodingKey {
        case id, localPath, remotePath, syncType, section, type, unwatched,
             partiallyWatched
    }

    @Published public var localPath: String
    @Published public var remotePath: String
    @Published public var syncType: SyncType
    public var section: String?
    public var unwatched = Set<URL>()
    public var partiallyWatched = Set<URL>()
    public var id = UUID()
    public var type: MediaType?

    public init(localPath: String = "", remotePath: String = "", syncType: SyncType = .file) {
        self.localPath = localPath
        self.remotePath = remotePath
        self.syncType = syncType
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.localPath = try container.decode(String.self, forKey: .localPath)
        self.remotePath = try container.decode(String.self, forKey: .remotePath)
        self.syncType = try container.decode(SyncType.self, forKey: .syncType)
        self.section = try container.decode(String?.self, forKey: .section)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.type = try container.decode(MediaType?.self, forKey: .type)
        self.unwatched = try container.decode(Set<URL>.self, forKey: .unwatched)
        self.partiallyWatched = try container.decode(Set<URL>.self, forKey: .partiallyWatched)
    }

    public static func == (lhs: PlexPath, rhs: PlexPath) -> Bool {
        return lhs.localPath == rhs.localPath
    }

    public var description: String {
        "PlexPath(localPath: \(localPath), remotePath: \(remotePath), section: \(section ?? ""), id: \(id)"
    }

    public var isValid: Bool { !localPath.isEmpty && !remotePath.isEmpty }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(localPath)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(localPath, forKey: .localPath)
        try container.encode(remotePath, forKey: .remotePath)
        try container.encode(syncType, forKey: .syncType)
        try container.encode(section, forKey: .section)
        try container.encode(type, forKey: .type)
        try container.encode(unwatched, forKey: .unwatched)
        try container.encode(partiallyWatched, forKey: .partiallyWatched)
    }
}

extension PlexPaths: RawRepresentable {
    public init?(rawValue: String) {
        guard let data = rawValue.data(using: .utf8),
              let result = try? JSONDecoder().decode(PlexPaths.self, from: data)
        else {
            return nil
        }
        self = result
    }

    public var rawValue: String {
        guard let data = try? JSONEncoder().encode(self),
              let result = String(data: data, encoding: .utf8)
        else {
            return "[]"
        }
        return result
    }
}
