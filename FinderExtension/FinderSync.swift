//
//  FinderSync.swift
//  FinderExtension
//
//  Created by Jacob Carlborg on 2023-08-20.
//

import Cocoa
import FinderSync
import LibPlexUnwatched
import SwiftUI

struct Badge {
    var image: NSImage
    var label: String
    var identifier: String
}

struct Location: Codable {
    var path: String
}

struct Directory: Codable {
    var key: String
    var Location: [Location]
}

struct MediaContainer: Codable {
    var Directory: [Directory]
}

private let store = UserDefaults(suiteName: "app-group.com.github.jacob-carlborg.PlexUnwatched")

class FinderSync: FIFinderSync {
    @AppStorage("plexPaths", store: store) private var plexPaths = PlexPaths()

    private let badges = [
        Badge(
            image: NSImage(named: "UnwatchedBadge")!,
            label: "Unwatched",
            identifier: "Unwatched"
        ),

        Badge(
            image: NSImage(named: "PartiallyWatchedBadge")!,
            label: "Partially Watched",
            identifier: "PartiallyWatched"
        )
    ]

    private lazy var syncedDirectories = Set(plexPaths.map { URL(fileURLWithPath: $0.localPath) })

    override init() {
        super.init()

        print("FinderSync() launched from: \(Bundle.main.bundlePath)")

        // Set up the directory we are syncing.
        controller.directoryURLs = syncedDirectories

        for badge in badges {
            controller.setBadgeImage(badge.image, label: badge.label, forBadgeIdentifier: badge.identifier)
        }
    }

    private var controller: FIFinderSyncController {
        FIFinderSyncController.default()
    }

    // MARK: - Primary Finder Sync protocol methods

    override func beginObservingDirectory(at url: URL) {
        // The user is now seeing the container's contents.
        // If they see it in more than one view at a time, we're only told once.
        print("beginObservingDirectoryAtURL: \(url.path)")
    }

    override func endObservingDirectory(at url: URL) {
        // The user is no longer seeing the container's contents.
        print("endObservingDirectoryAtURL: \(url.path)")
    }

    override func requestBadgeIdentifier(for url: URL) {
        let path: PlexPath? = plexPaths.first { url.path().hasPrefix($0.localPath) }

        if path?.unwatched.contains(url) ?? false {
            controller.setBadgeIdentifier("Unwatched", for: url)
        } else if path?.partiallyWatched.contains(url) ?? false {
            controller.setBadgeIdentifier("PartiallyWatched", for: url)
        }
    }

    // MARK: - Menu and toolbar item support

//    override var toolbarItemName: String {
//        return "FinderSy"
//    }
//
//    override var toolbarItemToolTip: String {
//        return "FinderSy: Click the toolbar item for a menu."
//    }
//
//    override var toolbarItemImage: NSImage {
//        return NSImage(named: NSImage.cautionName)!
//    }
//
//    override func menu(for menuKind: FIMenuKind) -> NSMenu {
//        // Produce a menu for the extension.
//        let menu = NSMenu(title: "")
//        menu.addItem(withTitle: "Example Menu Item", action: #selector(sampleAction(_:)), keyEquivalent: "")
//        return menu
//    }
//
//    @IBAction func sampleAction(_ sender: AnyObject?) {
//        let target = FIFinderSyncController.default().targetedURL()
//        let items = FIFinderSyncController.default().selectedItemURLs()
//
//        let item = sender as! NSMenuItem
//        NSLog("sampleAction: menu item: %@, target = %@, items = ", item.title as NSString, target!.path as NSString)
//        for obj in items! {
//            NSLog("    %@", obj.path as NSString)
//        }
//    }
}
