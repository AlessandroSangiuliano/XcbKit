//
//  XCBScreen.h
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xcb/xcb.h>

@class XCBWindow;

@interface XCBScreen : NSObject
{
	xcb_screen_t *screen;
	XCBWindow *rootWindow;
}

@property (nonatomic) uint16_t height;
@property (nonatomic) uint16_t width;

- (xcb_screen_t *) screen;
- (void) setScreen: (xcb_screen_t *) aScreen;
- (id) initWithXCBScreen:(xcb_screen_t *) aScreen andRootWindow:(XCBWindow*) theRootWindow;
+ (XCBScreen *) screenWithXCBScreen: (xcb_screen_t *) aScreen andRootWindow:(XCBWindow*)theRootWindow;
- (void) setRootWindow:(XCBWindow *) aRootWindow;
- (XCBWindow *) rootWindow;

@end
