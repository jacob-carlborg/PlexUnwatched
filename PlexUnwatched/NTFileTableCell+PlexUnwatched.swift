//
//  NTFileTableCell+PlexUnwatched.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSCell
{
  private static let diameter: CGFloat = 8.0
  private static let distance: CGFloat = 17.0

  private static var unwatchedStorage = [Int: Bool]()

  var unwatched: Bool
  {
    get { return NSCell.unwatchedStorage[hashValue] ?? false }
    set(unwatched) { NSCell.unwatchedStorage[hashValue] = unwatched }
  }

  func plex_unwatched_requiredTextWidth() -> UInt64
  {
    #if DEBUG
      NSLog("NTFileTableCell.plex_unwatched_requiredTextWidth")
    #endif

    let width = plex_unwatched_requiredTextWidth()
    return firstColumn() ? width - UInt64(NSCell.distance) : width
  }

  func plex_unwatched_rectsForBounds(rect: NSRect, imageRect: UnsafeMutablePointer<NSRect>, textRect: UnsafeMutablePointer<NSRect>, actionButtonRect: UnsafeMutablePointer<NSRect>)
  {
    #if DEBUG
      NSLog("NTFileTableCell.plex_unwatched_rectsForBounds")
    #endif

    plex_unwatched_rectsForBounds(rect, imageRect: imageRect, textRect: textRect, actionButtonRect: actionButtonRect)
    let rect = textRect.memory

    if rect.origin.x == 0.0 && rect.origin.y == 0 || !firstColumn() { return }

    textRect.memory.size.width -= NSCell.distance
  }

  func plex_unwatched_drawWithFrame(origialRect: NSRect, inView view: AnyObject)
  {
    #if DEBUG
      NSLog("NTFileTableCell.plex_unwatched_drawHotspotInCellFrame")
    #endif

    plex_unwatched_drawWithFrame(origialRect, inView: view)

    if !firstColumn() || !unwatched { return }

    var imageRect = CGRect()
    var textRect = CGRect()
    var actionButtonRect = CGRect()

    plex_unwatched_rectsForBounds(origialRect, imageRect: &imageRect, textRect: &textRect, actionButtonRect: &actionButtonRect)
    var rect = actionButtonRect

    if rect.origin.x == 0.0 && rect.origin.y == 0 { return }

    rect.origin.x -= NSCell.distance
    rect.origin.y += (rect.size.width - NSCell.diameter) / 2
    rect.size.width = NSCell.diameter
    rect.size.height = NSCell.diameter

    let context = NSGraphicsContext.currentContext()?.CGContext
    CGContextSetRGBFillColor(context, 0.902, 0.541, 0.11, 1.0)
    CGContextFillEllipseInRect(context, rect)
  }
}
