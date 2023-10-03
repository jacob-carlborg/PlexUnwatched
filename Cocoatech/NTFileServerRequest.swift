//
//  NTFileServerRequest.swift
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-12-06.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

import Foundation

extension NSObject
{
  @objc func isDirectoryRequest() -> Bool
  {
    assert(false, "Implemented in Path Finder, should never be called")
    return false
  }

                         // NTFileDesc
  @objc func directory() -> NSObject!
  {
    assert(false, "Implemented in Path Finder, should never be called")
    return nil
  }
}
