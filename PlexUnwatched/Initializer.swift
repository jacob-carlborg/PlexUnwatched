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
			try swizzleMethod("NTFileTableCell", originalSelector: "drawHotspotInCellFrame:inView:", withSelector: "plex_unwatched_drawHotspotInCellFrame:inView:")
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
