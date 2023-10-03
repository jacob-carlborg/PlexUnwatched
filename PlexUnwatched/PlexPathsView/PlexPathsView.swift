//
//  PlexPathsView.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2023-09-07.
//

import LibPlexUnwatched
import SwiftUI

struct PlexPathsView: View {
    enum TableField: Hashable {
        case local(id: UUID)
        case remote(id: UUID)
    }

    enum PathAction {
        case none
        case edit
        case add
    }

    @State private var plexPaths: [PlexPath]
    @State private var selectedPlexPaths = Set<PlexPath.ID>()
    @State private var removeButtonEnabled = false
    @State private var showingRemoveConfirmationDialog = false
    @ObservedObject private var plex: Plex
    @FocusState private var focusedTableField: TableField?
    @State private var pathAction = PathAction.none

    init(plex: Plex, paths: [PlexPath] = []) {
        self.plex = plex
        _plexPaths = State(initialValue: paths)
    }

    var body: some View {
        Table($plexPaths, selection: $selectedPlexPaths) {
            TableColumn("Local Path") { $path in
                TextField("", text: $path.localPath)
                    .focused($focusedTableField, equals: .local(id: $path.id))
            }

            TableColumn("Remote Path") { $path in
                TextField("", text: $path.remotePath)
                    .focused($focusedTableField, equals: .remote(id: $path.id))
            }

            TableColumn("Sync Type") { $path in
                Picker("", selection: $path.syncType) {
                    Text("File").tag(SyncType.file)
                    Text("Directory").tag(SyncType.directory)
                }.pickerStyle(.segmented)
            }

            TableColumn("UUID") { path in
                Text(path.id.description)
            }
        }
        .padding(.bottom, 24)
        .onChange(of: selectedPlexPaths) {
            removeButtonEnabled = !selectedPlexPaths.isEmpty
        }
        .onChange(of: focusedTableField) {
            focusedTableFieldDidChange(from: $0, to: $1)
        }
        .overlay(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                HStack(spacing: 0) {
                    Button(action: addPath) {
                        GradientButton(glyph: "plus")
                    }

                    Divider().frame(height: 16)

                    Button(action: { showingRemoveConfirmationDialog = true }) {
                        GradientButton(glyph: "minus")
                    }
                    .disabled(!removeButtonEnabled)
                    .keyboardShortcut(.delete)
                    .confirmationDialog("Are you sure you want to remove \(selectedPlexPaths.count) paths", isPresented: $showingRemoveConfirmationDialog) {
                        Button("Remove Paths", role: .destructive, action: removePaths)
                    }
                }
                .buttonStyle(.borderless)
            }
        }
    }

    private func removePaths() {
        plexPaths.removeAll(where: { selectedPlexPaths.contains($0.id) })
        plex.didRemovePaths(selectedPlexPaths)
        selectedPlexPaths.removeAll(keepingCapacity: true)
    }

    private func addPath() {
        pathAction = .add
        let path = PlexPath()
        plexPaths.append(path)
        focusedTableField = .local(id: path.id)
    }

    private func pathEdited(_ path: PlexPath) {
        print("pathEdited ", path)
    }

    private func focusedTableFieldDidChange(from oldValue: TableField?, to newValue: TableField?) {
        if newValue == nil {
            pathEditDidComplete(previousFocus: oldValue)
        } else if pathAction == .none {
            pathAction = .edit
        }
    }

    func pathEditDidComplete(previousFocus previousFocusedTableField: TableField?) {
        var changedPath: PlexPath? {
            switch previousFocusedTableField {
            case .local(let id), .remote(let id):
                plexPaths.first { $0.id == id }
            case .none:
                nil
            }
        }

        guard let changedPath else { return }

        let action = switch pathAction {
        case .add: { await plex.addPath(changedPath) }
        case .edit: { plex.didChangePath(changedPath) }
        case .none: {}
        }

        pathAction = .none

        if changedPath.isValid {
            Task {
                await action()
            }
        }
    }
}

struct PlexPathsView_Previews: PreviewProvider {
    @StateObject static var plex = Plex()
    @State static var paths = [
        PlexPath(localPath: "/this/is/a/local/path", remotePath: "/remote/path"),
        PlexPath(localPath: "/another/local/path", remotePath: "/more/remote/path")
    ]

    static var previews: some View {
        PlexPathsView(plex: plex, paths: paths)
    }
}
