//
//  ContentView.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2023-08-20.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var plex = Plex()

    var body: some View {
        VStack(alignment: .trailing) {
            Form {
                Section {
                    TextField("", text: $plex.typedPlexServerUrl, prompt: Text("Plex Server URL"))
                }

                Section {
                    PlexPathsView(plex: plex, paths: plex.paths)
                }
            }.formStyle(.grouped)
            Divider()
            Button {} label: {
                Image(systemName: "arrow.clockwise")
            }
            .keyboardShortcut(KeyEquivalent("r"), modifiers: .command)
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
