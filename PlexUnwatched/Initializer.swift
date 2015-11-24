//
//  Setup.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-24.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

class Initializer : NSObject
{
  static func setup()
  {
    #if DEBUG
      NSLog("Initializer.setup")
    #endif

    do
    {
      try swizzleMethod("NTFileTableCell", originalSelector: "drawWithFrame:inView:", withSelector: "plex_unwatched_drawWithFrame:inView:")
      try swizzleMethod("NTFileTableCell", originalSelector: "rectsForBounds:imageRect:textRect:actionButtonRect:", withSelector: "plex_unwatched_rectsForBounds:imageRect:textRect:actionButtonRect:")
      try swizzleMethod("NTFileTableCell", originalSelector: "requiredTextWidth", withSelector: "plex_unwatched_requiredTextWidth")

      try swizzleMethod("ListView", originalSelector: "preparedCellAtColumn:row:", withSelector: "plex_unwatched_preparedCellAtColumn:row:")
      try swizzleMethod("ListViewController", originalSelector: "dataMgr_didUpdateRequest:isRootRequest:rootIsNewLocation:savedState:", withSelector: "plex_unwatched_dataMgr_didUpdateRequest:isRootRequest:rootIsNewLocation:savedState:")
      try swizzleMethod("NTBrowserViewController", originalSelector: "sendDelayedServerRequestChangedNotification:", withSelector: "plex_unwatched_sendDelayedServerRequestChangedNotification:")
    }
    catch let error as SwizzleError
    {
      NSLog(error.description)
    }
    catch
    {
      NSLog("Unexpected error");
    }
  }
}
