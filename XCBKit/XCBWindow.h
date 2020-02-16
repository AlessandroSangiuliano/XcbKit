//
//  XCBWindow.h
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBRect.h"
#include <xcb/xcb.h>

@interface XCBWindow : NSObject
{
	xcb_window_t window;
	XCBWindow *parentWindow;
	XCBWindow *aboveWindow;
	BOOL isMapped;
	xcb_get_window_attributes_reply_t attributes;
    uint32_t windowMask;
}

@property (nonatomic) xcb_gcontext_t graphicContextId;
@property (strong, nonatomic) XCBRect *windowRect;
@property (nonatomic) BOOL decorated;
@property (nonatomic) BOOL draggable;


- (xcb_window_t) window;
- (void) setWindow:(xcb_window_t) aWindow;
- (NSString*) windowIdStringValue;

- (id) initWithXCBWindow:(xcb_window_t) aWindow;


- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow*) aParent;

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow*) aParent
		 withAboveWindow:(XCBWindow*) anAbove;

- (xcb_void_cookie_t) createGraphicContextWithMask:(uint32_t) aMask andValues:(uint32_t*) values;

- (XCBWindow*) parentWindow;
- (XCBWindow*) aboveWindow;
- (void) setParentWindow:(XCBWindow*) aParent;
- (void) setAboveWindow:(XCBWindow*) anAbove;
- (void) setIsMapped:(BOOL) mapped;
- (BOOL) isMapped;
- (xcb_get_window_attributes_reply_t) attributes;
- (void) setAttributes:(xcb_get_window_attributes_reply_t) someAttributes;
- (void) setWindowMask:(uint32_t) aMask;
- (uint32_t) windowMask;
- (void) setWindowBorderWidth:(uint32_t)border;

-(void) description;


@end