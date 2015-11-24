//
//  NTBrowserViewController+PlexUnwatched.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSObject
{
                                                                        // NTFileServerRequest
  func plex_unwatched_sendDelayedServerRequestChangedNotification(request: NSObject!)
  {
    #if DEBUG
      NSLog("NTBrowserViewController.plex_unwatched_sendDelayedServerRequestChangedNotification")
    #endif

    plex_unwatched_sendDelayedServerRequestChangedNotification(request)

    guard request.isDirectoryRequest() else { return }
    guard let directory = request.directory() else { return }
    guard let path = directory.path() else { return }

    if directory.isValid() && directory.isDirectory() && !path.isEmpty
    {
      PlexUnwatchedPlugin.sharedInstance.currentPath = path
    }
  }
}
