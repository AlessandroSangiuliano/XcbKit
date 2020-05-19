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

@class XCBConnection;

@interface XCBWindow : NSObject
{
	xcb_window_t window;
	XCBWindow *parentWindow;
	XCBWindow *aboveWindow;
	BOOL isMapped;
	xcb_get_window_attributes_reply_t attributes;
    uint32_t windowMask;
}


typedef NS_ENUM(NSInteger, WindowState)
{
    ICCCM_WM_STATE_WITHDRAWN = 0,
    ICCCM_WM_STATE_NORMAL = 1,
    ICCCM_WM_STATE_ICONIC = 3
};

@property (nonatomic) xcb_gcontext_t graphicContextId;
@property (strong, nonatomic) XCBRect *windowRect;
@property (strong, nonatomic) XCBRect* oldRect;
@property (strong, nonatomic) XCBRect* originalRect;
@property (nonatomic) BOOL decorated;
@property (nonatomic) BOOL draggable; //TODO: forse no nmi serve
@property (nonatomic) BOOL isCloseButton;
@property (nonatomic) BOOL isMinimizeButton;
@property (nonatomic) BOOL isMaximizeButton;
@property (nonatomic) BOOL isMaximized;
@property (nonatomic) BOOL isMinimized;
@property (nonatomic) XCBConnection* connection;
@property (nonatomic) BOOL needDestroy;
@property (nonatomic) xcb_pixmap_t pixmap;
@property (nonatomic) BOOL firstRun; //find a better solution



- (xcb_window_t) window;
- (void) setWindow:(xcb_window_t) aWindow;
- (NSString*) windowIdStringValue;

- (id) initWithXCBWindow:(xcb_window_t) aWindow
           andConnection:(XCBConnection*)aConnection;


- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow*) aParent
           andConnection:(XCBConnection*) aConnection;

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow*) aParent
		 withAboveWindow:(XCBWindow*) anAbove
          withConnection:(XCBConnection*) aConnection;

- (xcb_void_cookie_t) createGraphicContextWithMask:(uint32_t) aMask andValues:(uint32_t*) values;
- (void) createPixmap;

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

- (void) maximizeToWidth:(uint16_t)width andHeight:(uint16_t)height;
- (void) minimize;
- (void) hide;
- (void) restoreDimensionAndPosition;
- (void) createMiniWindowAtPosition:(XCBPoint*)position;
- (void) restoreFromIconified;
- (void) destroy;
- (void) stackAbove;
- (void) stackBelow;
- (void) grabButton;
- (void) ungrabButton;
- (void) description;


@end