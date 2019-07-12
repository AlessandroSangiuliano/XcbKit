//
//  XCBScreen.m
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBScreen.h"

@implementation XCBScreen

+ (XCBScreen*) screenWithXCBScreen:(xcb_screen_t *)aScreen
{
	return [[self alloc] initWithXCBScreen:aScreen];
}


- (xcb_screen_t ) screen
{
	return screen;
}

- (void) setScreen:(xcb_screen_t *)aScreen
{
	if (aScreen == NULL)
	{
		NSLog(@"[XCBScreen] The screen is null.");
		return;
	}
	
	screen = *aScreen;
}

- (id) initWithXCBScreen:(xcb_screen_t *) aScreen
{
	self = [super init];
	screen = *aScreen;
	rootWindow = [[XCBWindow alloc] initWithXCBWindow:aScreen->root];
	
	if (self == nil)
	{
		NSLog(@"[XCBScreen] Init failed.");
		return nil;
	}
	
	return self;
}

- (void) setRootWindow:(XCBWindow *)aRootWindow
{
	rootWindow = aRootWindow;
}

- (XCBWindow *) rootWindow
{
	return rootWindow;
}

- (void) dealloc
{
	rootWindow = nil;
}

@end
