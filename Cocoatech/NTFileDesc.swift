//
//  NTFileDesc.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSObject
{
  @objc func isValid() -> Bool
  {
    assert(false, "Implemented in Path Finder, should never be called")
    return false
  }

  @objc func path() -> String!
  {
    assert(false, "Implemented in Path Finder, should never be called")
    return nil
  }

  @objc func isDirectory() -> Bool
  {
    assert(false, "Implemented in Path Finder, should never be called")
    return false
  }
}
