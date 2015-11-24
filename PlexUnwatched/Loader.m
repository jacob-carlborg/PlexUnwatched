//
//  Loader.m
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-24.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlexUnwatched-Swift.h"

@interface Loader : NSObject
@end

@implementation Loader

+ (void)load
{
#if DEBUG
	NSLog(@"Loader.load");
#endif
	[Initializer setup];
}

@end
