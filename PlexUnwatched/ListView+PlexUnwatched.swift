//
//  ListView+PlexUnwatched.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSOutlineView
{
  func plex_unwatched_preparedCellAtColumn(column: Int, row: Int) -> NSCell?
  {
    #if DEBUG
      NSLog("ListView.plex_unwatched_preparedCellAtColumn")
    #endif

    let cell = plex_unwatched_preparedCellAtColumn(column, row: row)
    let unwatched = PlexUnwatchedPlugin.sharedInstance.isUnwatchedRow(row)
    cell?.unwatched = unwatched

    return cell
  }
}
