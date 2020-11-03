//
//  XCBWindow.h
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils/XCBShape.h"
#import "XCBGeometryReply.h"
#include <xcb/xcb.h>
#import "XCBQueryTreeReply.h"
#import "XCBScreen.h"
#import "XCBAttributesReply.h"
#import "XCBVisual.h"

@class XCBConnection;

@interface XCBWindow : NSObject
{
	xcb_window_t window;
	XCBWindow *parentWindow;
	XCBWindow *aboveWindow;
	BOOL isMapped;
    uint32_t windowMask;
}


typedef NS_ENUM(NSInteger, WindowState)
{
    ICCCM_WM_STATE_WITHDRAWN = 0,
    ICCCM_WM_STATE_NORMAL = 1,
    ICCCM_WM_STATE_ICONIC = 3
};

@property (nonatomic) xcb_gcontext_t graphicContextId;
@property (nonatomic) XCBRect windowRect;
@property (nonatomic) XCBRect oldRect;
@property (nonatomic) XCBRect originalRect;
@property (nonatomic) BOOL decorated;
@property (nonatomic) BOOL isCloseButton;
@property (nonatomic) BOOL isMinimizeButton;
@property (nonatomic) BOOL isMaximizeButton;
@property (nonatomic) BOOL isMaximized;
@property (nonatomic) BOOL isMinimized;
@property (nonatomic) XCBConnection* connection;
@property (nonatomic) BOOL needDestroy;
@property (nonatomic) xcb_pixmap_t pixmap;
@property (nonatomic) BOOL firstRun; //find a better solution
@property (nonatomic) BOOL pointerGrabbed;
@property (strong, nonatomic) NSMutableArray* allowedActions;
@property (nonatomic) BOOL isAbove;
@property (nonatomic) XCBSize pixmapSize;
@property (strong, nonatomic) NSMutableArray *icons;
@property (strong, nonatomic) XCBScreen *screen;
@property (strong, nonatomic) XCBAttributesReply *attributes;


/*** ALLOWED ACTIONS ***/

@property (nonatomic) BOOL canMove;
@property (nonatomic) BOOL canResize;
@property (nonatomic) BOOL canMinimize;
@property (nonatomic) BOOL canMaximizeVert;
@property (nonatomic) BOOL canMaximizeHorz;
@property (nonatomic) BOOL canFullscreen;
@property (nonatomic) BOOL canChangeDesktop;
@property (nonatomic) BOOL canClose;
@property (nonatomic) BOOL canShade;
@property (nonatomic) BOOL canStick;


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
- (void) destroyGraphicsContext;
- (void) createPixmap;
- (void) createPixmapDelayed;
- (void) destroyPixmap;
- (void) updatePixmap;

- (XCBWindow*) parentWindow;
- (XCBWindow*) aboveWindow;
- (void) setParentWindow:(XCBWindow*) aParent;
- (void) setAboveWindow:(XCBWindow*) anAbove;
- (void) setIsMapped:(BOOL) mapped;
- (BOOL) isMapped;
- (void) updateAttributes;
- (void) setWindowMask:(uint32_t) aMask;
- (uint32_t) windowMask;
- (void) setWindowBorderWidth:(uint32_t)border;
- (void) checkNetWMAllowedActions;
- (XCBQueryTreeReply*) queryTree;
- (XCBScreen*) onScreen;
- (XCBVisual*) visual;

- (void) maximizeToWidth:(uint16_t)width andHeight:(uint16_t)height;
- (void) minimize;
- (void) hide;
- (void) restoreDimensionAndPosition;
- (void) createMiniWindowAtPosition:(XCBPoint)position;
- (void) restoreFromIconified;
- (void) destroy;
- (void) stackAbove;
- (void) stackBelow;
- (void) grabButton;
- (void) ungrabButton;
- (void) description;
- (BOOL) grabPointer;
- (void) ungrabPointer;
- (XCBGeometryReply*) geometries;
- (XCBRect) rectFromGeometries;
- (void) updateRectsFromGeometries;
- (void) configureForEvent:(xcb_configure_request_event_t *)anEvent;
- (void) drawIcons;
- (void) cairoPreview;


@end
