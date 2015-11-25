//
//  PlexUnwatchedPlugin.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-21.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Cocoa

@objc class PlexUnwatchedPlugin : NSObject, NTMenuPluginProtocol
{
	static var host: NTPathFinderPluginHostProtocol? = nil

	static func plugin(host: NTPathFinderPluginHostProtocol!) -> AnyObject!
	{
		#if DEBUG
			NSLog("PlexUnwatchedPlugin.plugin")
		#endif

		PlexUnwatchedPlugin.host = host

		return PlexUnwatchedPlugin()
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
}
