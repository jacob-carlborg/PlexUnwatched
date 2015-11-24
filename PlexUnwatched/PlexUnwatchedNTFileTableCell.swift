//
//  PlexUnwatchedNSCell.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-23.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Cocoa

extension NSCell
{
	@objc func rectsForBounds(rect: CGRect, imageRect: UnsafeMutablePointer<CGRect>, textRect: UnsafeMutablePointer<CGRect>, actionButtonRect: UnsafeMutablePointer<CGRect>)
	{
		// implemeneted in Path Finder
		#if DEBUG
			NSLog("PlexUnwatchedNTFileTableCell.rectsForBounds: should never be called")
		#endif
	}

	func plex_unwatched_drawHotspotInCellFrame(origialRect: CGRect, inView view: AnyObject)
	{
		struct Static
		{
			static let diameter: CGFloat = 8.0
		}

//		#if DEBUG
//			NSLog("PlexUnwatchedNTFileTableCell.plex_unwatched_drawHotspotInCellFrame")
//		#endif

		plex_unwatched_drawHotspotInCellFrame(origialRect, inView: view)

		var imageRect = CGRect()
		var textRect = CGRect()
		var actionButtonRect = CGRect()

		rectsForBounds(origialRect, imageRect: &imageRect, textRect: &textRect, actionButtonRect: &actionButtonRect)
		var rect = actionButtonRect

		if rect.origin.x == 0.0 && rect.origin.y == 0 { return }

		rect.origin.x -= rect.size.width
		rect.origin.y += (rect.size.width - Static.diameter) / 2
		rect.size.width = Static.diameter
		rect.size.height = Static.diameter

		let context = NSGraphicsContext.currentContext()?.CGContext
		CGContextSetRGBFillColor(context, 0.902, 0.541, 0.11, 1.0)
		CGContextFillEllipseInRect(context, rect)
	}
}
