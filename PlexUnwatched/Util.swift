//
//  Util.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-21.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSObjectProtocol
{
	func tap(block: (Self) -> Void) -> Self
	{
		block(self)
		return self
	}
}

enum SwizzleError : ErrorType
{
	case ClassNotFound(name: String)
	case FailedToSwizzleMethod(methodName: String, className: String, description: String)

	var description: String
	{
		switch self
		{
			case .ClassNotFound(let className): return "Failed to find the class '\(className)'"
			case .FailedToSwizzleMethod(let methodName, let className, let description):
				return "Failed to sizzle method '\(methodName)' on '\(className)', reason: \(description)"
		}
	}
}

func swizzleMethod(className: String, originalSelector: Selector, withSelector: Selector) throws
{
	guard let cls = objc_getClass(className) as? NSObject.Type else
	{
		throw SwizzleError.ClassNotFound(name: className)
	}

	do
	{
		try cls.jr_swizzleMethod(originalSelector, withMethod: withSelector)
	}

	catch let error as NSError
	{
		let methodName = NSStringFromSelector(originalSelector)
		throw SwizzleError.FailedToSwizzleMethod(methodName: methodName, className: className, description: error.description)
	}
}
