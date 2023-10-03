//
//  ListViewController+PlexUnwatched.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSObject
{
                                                     // NTFileServerRequest
  func plex_unwatched_dataMgr_didUpdateRequest(request: NSObject, isRootRequest: Bool, rootIsNewLocation: Bool, savedState: NSObject)
  {
    #if DEBUG
      NSLog("ListViewController.plex_unwatched_dataMgr_didUpdateRequest 1")
    #endif

    plex_unwatched_dataMgr_didUpdateRequest(request, isRootRequest: isRootRequest, rootIsNewLocation: rootIsNewLocation, savedState: savedState)

    let items = visibleItems().map { $0.rawPath().description }
    PlexUnwatchedPlugin.sharedInstance.dataMgr_didUpdateRequest(items)
  }
}
