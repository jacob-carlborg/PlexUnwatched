//
//  MethodPrinter.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

struct MethodPrinter
{
  /// Print the names for each method in a class with a specified name
  static func printMethods(classname: String)
  {
    if let cls: AnyClass = NSClassFromString(classname) {
      printMethodNamesForClass(cls)
    }
    else {
      print("\(classname): no such class")
    }
  }

  private static func enumerateCArray<T>(array: UnsafePointer<T>, count: UInt32, f: (UInt32, T) -> ())
  {
    var ptr = array

    for i in 0..<count {
      f(i, ptr.memory)
      ptr = ptr.successor()
    }
  }

  /// Return name for a method
  private static func methodName(m: Method) -> String?
  {
    let sel = method_getName(m)
    let nameCString = sel_getName(sel)
    return String.fromCString(nameCString)
  }

  /// Print the names for each method in a class
  private static func printMethodNamesForClass(cls: AnyClass)
  {
    var methodCount: UInt32 = 0
    let methodList = class_copyMethodList(cls, &methodCount)

    if methodList != nil && methodCount > 0 {
      enumerateCArray(methodList, count: methodCount) { i, m in
        let name = methodName(m) ?? "unknown"
        print("#\(i): \(name)")
      }

      free(methodList)
    }
  }
}
