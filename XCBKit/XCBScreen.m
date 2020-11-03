//
//  XCBScreen.m
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBScreen.h"
#import "XCBWindow.h"

@implementation XCBScreen

@synthesize height;
@synthesize width;
@synthesize screenNumber;

+ (XCBScreen*) screenWithXCBScreen:(xcb_screen_t *)aScreen andRootWindow:(XCBWindow*)theRootWindow
{
	return [[self alloc] initWithXCBScreen:aScreen andRootWindow:theRootWindow];
}


- (xcb_screen_t *) screen
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
	
	screen = aScreen;
}

- (id) initWithXCBScreen:(xcb_screen_t *) aScreen andRootWindow:(XCBWindow *)theRootWindow
{
	self = [super init];
	screen = aScreen;
	rootWindow = theRootWindow;
    width = aScreen->width_in_pixels;
    height = aScreen->height_in_pixels;
	
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

- (void) description
{
    NSLog(@"Screen number: %hd", screenNumber);
}

- (void) dealloc
{
	rootWindow = nil;
    free(screen);
}

@end
