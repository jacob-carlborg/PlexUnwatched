//
//  Loader.m
//  PlexUnwatched
//
//  Created by Jacob Carlborg on 2015-11-24.
//  Copyright © 2015 Jacob Carlborg. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "PlexUnwatched-Swift.h"
#import "NTMenuPluginProtocol.h"

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

/*@interface PlexUnwatchedPlugin : NSObject <NTMenuPluginProtocol>
@end

@implementation PlexUnwatchedPlugin

+ (id)plugin:(id<NTPathFinderPluginHostProtocol>)host;
{
	id result = [[self alloc] init];
	NSLog(@"************************** PlexUnwatchedPlugin.plugin");

	return result;
}

- (NSMenuItem*)contextualMenuItem;
{
	//NSLog(@"contextualMenuItem *************************");
	return [self menuItem];
}

- (NSMenuItem*)menuItem
{
	return nil;
}

- (id)processItems:(NSArray*)items parameter:(id)parameter
{
	//NSLog(@"processItems *************************");
	// do nothing
	return nil;
}

@end*/