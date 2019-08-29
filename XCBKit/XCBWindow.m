//
//  XCBWindow.m
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBWindow.h"
#import "XCBConnection.h"

@implementation XCBWindow

@synthesize graphicContextId;
@synthesize windowRect;
@synthesize drawableWindow;

- (id) initWithXCBWindow:(xcb_window_t)aWindow
{
	return [self initWithXCBWindow:aWindow
				  withParentWindow:XCB_NONE
				   withAboveWindow:XCB_NONE];
}

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow *) aParent
{
	return [self initWithXCBWindow:aWindow
				  withParentWindow:aParent
				   withAboveWindow:XCB_NONE];
}

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow *) aParent
		 withAboveWindow:(XCBWindow *) anAbove
{
	self = [super init];
	window = aWindow;
	parentWindow = aParent;
	aboveWindow = anAbove;
	isMapped = NO;
	
	return self;
}

- (xcb_void_cookie_t) createGraphicContext
{
    uint32_t value[1];
    graphicContextId = xcb_generate_id([XCBConn connection]);
    XCBScreen *screen = [[XCBConn screens] objectAtIndex:0];
    
    xcb_screen_t scr = [screen screen];
    value[0] = scr.black_pixel;
    
    xcb_void_cookie_t gcCookie = xcb_create_gc([XCBConn connection],
                                               graphicContextId,
                                               window,
                                               XCB_GC_FOREGROUND,
                                               value);
    
    return gcCookie;
    
}

- (xcb_window_t) window
{
	return window;
}

- (void) setWindow:(xcb_window_t )aWindow
{
	window = aWindow;
}

- (NSString*) windowIdStringValue
{
	NSString *stringId = [NSString stringWithFormat:@"%u", window];
	return stringId;
}

- (XCBWindow*) parentWindow
{
	return parentWindow;
}

- (XCBWindow*) aboveWindow
{
	return aboveWindow;
}

- (void) setParentWindow:(XCBWindow *)aParent
{
	parentWindow = aParent; 
}

- (void) setAboveWindow:(XCBWindow *)anAbove
{
	aboveWindow = anAbove;
}

- (void) setIsMapped:(BOOL) mapped
{
	isMapped = mapped;
}

- (BOOL) isMapped
{
	return isMapped;
}

- (xcb_get_window_attributes_reply_t) attributes
{
	return attributes;
}

- (void) setAttributes:(xcb_get_window_attributes_reply_t)someAttributes
{
	attributes = someAttributes;
}

- (void) description
{
    NSLog(@"Ciao belli");
}
	 
- (void) dealloc
{
	parentWindow = nil;
	aboveWindow = nil;
}

@end
