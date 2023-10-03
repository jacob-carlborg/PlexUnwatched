//
//  PlexUnwatchedPlugin.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-21.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Cocoa

import Alamofire
import SwiftyJSON

struct PlexSection
{
  var localPath: String
  var remotePath: String
  var section: Int
}

@objc class PlexUnwatchedPlugin : NSObject, NTMenuPluginProtocol
{
  static let sharedInstance = PlexUnwatchedPlugin()

  static let plexSections = [
    PlexSection(
      localPath: "/Volumes/doob/Movies",
      remotePath: "/Users/doob/Movies",
      section: 1
    ),

    PlexSection(
      localPath: "/Volumes/doob/TV Shows",
      remotePath: "/Users/doob/TV Shows",
      section: 2
    )
  ]

  static let plexServerURL = "http://192.168.0.4:32400"
  static let headers = ["Accept": "application/json"]

  var currentPath = String()

  private var lastPath = String()
  private var unwatchedCache = Set<String>()
  private var unwatchedMappings = [Bool]()

  static func plugin(_: NTPathFinderPluginHostProtocol!) -> AnyObject!
  {
    #if DEBUG
      NSLog("PlexUnwatchedPlugin.plugin")
    #endif

    return PlexUnwatchedPlugin.sharedInstance
  }

  func menuItem() -> NSMenuItem!
  {
    #if DEBUG
      NSLog("PlexUnwatchedPlugin.menuItem")
    #endif

    return nil
  }

  func contextualMenuItem() -> NSMenuItem!
  {
    #if DEBUG
      NSLog("PlexUnwatchedPlugin.contextualMenuItem")
    #endif

    return nil
  }

  func processItems(items: [AnyObject]!, parameter: AnyObject!) -> AnyObject!
  {
    #if DEBUG
      NSLog("PlexUnwatchedPlugin.processItems")
    #endif

    return nil
  }

  func isUnwatchedRow(row: Int) -> Bool
  {
    return row >= 0 && row < unwatchedMappings.count ? unwatchedMappings[row] : false
  }

  func dataMgr_didUpdateRequest(visibleItems: [String])
  {
    guard let section = isPathTrackedByPlex(currentPath)
    else
    {
      clearUnwatchedMappings()
      return
    }

    if hasCurrentPathChanged()
    {
      lastPath = currentPath

      fetchUnwatchedPaths(section.section) {
        self.updateUnwatchedMappings(
          visibleItems,
          localPrefix: section.localPath,
          remotePrefix: section.remotePath
        )
      }
    }

    else
    {
      updateUnwatchedMappings(
        visibleItems,
        localPrefix: section.localPath,
        remotePrefix: section.remotePath
      )
    }
  }

  func hasCurrentPathChanged() -> Bool
  {
    return lastPath.isEmpty || lastPath != currentPath
  }

  private func isPathTrackedByPlex(directory: String) -> PlexSection?
  {
    let sections = PlexUnwatchedPlugin.plexSections
    return sections.find { directory.hasPrefix($0.localPath) }
  }

  private func fetchUnwatchedPaths(section: Int, block: () -> Void)
  {
    let url = PlexUnwatchedPlugin.plexServerURL + "/library/sections/\(section)/unwatched"

    Alamofire.request(.GET, url, headers: PlexUnwatchedPlugin.headers).responseJSON { response in
      guard let json = response.result.value else { return }

      let optionalFiles = JSON(json)["_children"].array?.map { child in
        child["_children"].array?.first?["_children"].array?.first?["file"].string
      }.flatMap { $0?.stringByRemovingPercentEncoding }

      if let files = optionalFiles
      {
        self.unwatchedCache = Set(files)
        block()
      }
    }
  }

  private func updateUnwatchedMappings(visibleItems: [String], localPrefix: String, remotePrefix: String)
  {
    let localPrefixLength = localPrefix.characters.count
    let remotePrefixLength = remotePrefix.characters.count

    let contentsWithoutPrefix: [String] = visibleItems.map {
      let pathCount = $0.characters.count
      assert(pathCount > localPrefixLength, "Length of \($0) is not greater than length of \(localPrefix)")
      return $0[localPrefixLength..<pathCount]
    }

    let unwatchedPathsWithoutPrefix = unwatchedCache.map {
      $0[remotePrefixLength..<$0.characters.count]
    }

    self.unwatchedMappings = contentsWithoutPrefix.map {
      unwatchedPathsWithoutPrefix.contains($0)
    }
  }

  private func clearUnwatchedMappings()
  {
    for (index, _) in unwatchedMappings.enumerate()
    {
      unwatchedMappings[index] = false
    }
  }
}
