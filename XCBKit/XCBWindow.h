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
#import "XCBCursor.h"
#import "XCBShape.h"

#define CLIENT_SELECT_INPUT_EVENT_MASK XCB_EVENT_MASK_STRUCTURE_NOTIFY \
                                        | XCB_EVENT_MASK_PROPERTY_CHANGE \
                                        | XCB_EVENT_MASK_FOCUS_CHANGE

#define ROOT_WINDOW_EVENT_MASK \
XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT \
| XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY \
| XCB_EVENT_MASK_ENTER_WINDOW \
| XCB_EVENT_MASK_LEAVE_WINDOW \
| XCB_EVENT_MASK_STRUCTURE_NOTIFY \
| XCB_EVENT_MASK_BUTTON_PRESS \
| XCB_EVENT_MASK_BUTTON_RELEASE \
| XCB_EVENT_MASK_FOCUS_CHANGE \
| XCB_EVENT_MASK_PROPERTY_CHANGE

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

@property (nonatomic, assign) xcb_gcontext_t graphicContextId;
@property (nonatomic, assign) XCBRect windowRect;
@property (nonatomic, assign) XCBRect oldRect;
@property (nonatomic, assign) XCBRect originalRect;
@property (nonatomic, assign) BOOL decorated;
@property (nonatomic, assign) BOOL isCloseButton;
@property (nonatomic, assign) BOOL isMinimizeButton;
@property (nonatomic, assign) BOOL isMaximizeButton;
@property (nonatomic) XCBConnection* connection;
@property (nonatomic, assign) BOOL needDestroy;
@property (nonatomic, assign) xcb_pixmap_t pixmap;
@property (nonatomic, assign) xcb_pixmap_t dPixmap;
@property (nonatomic, assign) BOOL firstRun; //find a better solution
@property (nonatomic, assign) BOOL pointerGrabbed;
@property (strong, nonatomic) NSMutableArray* allowedActions;
@property (nonatomic, assign) XCBSize pixmapSize;
@property (strong, nonatomic) NSMutableArray *icons;
@property (strong, nonatomic) XCBScreen *screen;
@property (strong, nonatomic) XCBAttributesReply *attributes;
@property (nonatomic, assign) BOOL isFocused;
@property (strong, nonatomic) NSMutableDictionary *cachedWMHints;
@property (assign, nonatomic) BOOL hasInputHint;
@property (strong, nonatomic) XCBCursor *cursor;
@property (strong, nonatomic) NSMutableArray *windowClass;
@property (strong, nonatomic) NSString *windowType;
@property (strong, nonatomic) XCBWindow *leaderWindow;
@property (strong, nonatomic) XCBShape* shape;

/*** _NET_WM_STATE ***/

@property (nonatomic, assign) BOOL skipTaskBar;
@property (nonatomic, assign) BOOL skipPager;
@property (nonatomic, assign) BOOL isAbove;
@property (nonatomic, assign) BOOL isBelow;
@property (nonatomic, assign) BOOL maximizedVertically;
@property (nonatomic, assign) BOOL maximizedHorizontally;
@property (nonatomic, assign) BOOL shaded;
@property (nonatomic, assign) BOOL isMaximized;
@property (nonatomic, assign) BOOL isMinimized;
@property (nonatomic, assign) BOOL fullScreen;
@property (nonatomic, assign) BOOL gotAttention;

/*** ALLOWED ACTIONS ***/

@property (nonatomic, assign) BOOL canMove;
@property (nonatomic, assign) BOOL canResize;
@property (nonatomic, assign) BOOL canMinimize;
@property (nonatomic, assign) BOOL canMaximizeVert;
@property (nonatomic, assign) BOOL canMaximizeHorz;
@property (nonatomic, assign) BOOL canFullscreen;
@property (nonatomic, assign) BOOL canChangeDesktop;
@property (nonatomic, assign) BOOL canClose;
@property (nonatomic, assign) BOOL canShade;
@property (nonatomic, assign) BOOL canStick;
@property (nonatomic, assign) BOOL alwaysOnTop;

/*** _NET_WM_PID ***/

@property (nonatomic, assign) u_int32_t pid;


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
- (void) clearArea:(XCBRect)aRect generatesExposure:(BOOL)aValue;
- (void) drawArea:(XCBRect)aRect;

- (XCBWindow*) parentWindow;
- (XCBWindow*) aboveWindow;
- (void) setParentWindow:(XCBWindow*) aParent;
- (void) setAboveWindow:(XCBWindow*) anAbove;
- (void) setIsMapped:(BOOL) mapped;
- (BOOL) isMapped;
- (void) updateAttributes;
- (BOOL) changeAttributes:(uint32_t[])values withMask:(uint32_t)aMask checked:(BOOL)check;
- (void) setWindowMask:(uint32_t) aMask;
- (uint32_t) windowMask;
- (void) setWindowBorderWidth:(uint32_t)border;
- (void) checkNetWMAllowedActions;
- (XCBQueryTreeReply*) queryTree;
- (XCBScreen*) onScreen;
- (XCBVisual*) visual;

- (void) maximizeToSize:(XCBSize)aSize andPosition:(XCBPoint)aPosition;
- (void) minimize;
- (void) hide;
- (void) close;
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
- (void) focus;
- (void) setIconicState;
- (void) setNormalState;
- (void) refreshCachedWMHints;
- (void) setInputFocus:(uint8_t)revertTo time:(xcb_timestamp_t)timestamp;
- (void) initCursor;
- (void) showLeftPointerCursor;
- (void) showResizeCursorForPosition:(MousePosition)position;
- (void) shade;
- (void) putWindowBackgroundWithPixmap:(xcb_pixmap_t)aPixmap;
- (void) refreshBorder;
- (void) generateWindowIcons;
- (BOOL) updatePid;

@end
