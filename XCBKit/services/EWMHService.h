//
//  EWMH.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../XCBConnection.h"
#import "../XCBWindow.h"
#import "XCBAtomService.h"

/*** define motif stuff in this class ***/

#define MWM_HINTS_FUNCTIONS   (1L << 0)
#define MWM_HINTS_DECORATIONS (1L << 1)
#define MWM_HINTS_INPUT_MODE  (1L << 2)
#define MWM_HINTS_STATUS      (1L << 3)

/* functions */
#define MWM_FUNC_ALL          (1L << 0)
#define MWM_FUNC_RESIZE       (1L << 1)
#define MWM_FUNC_MOVE         (1L << 2)
#define MWM_FUNC_MINIMIZE     (1L << 3)
#define MWM_FUNC_MAXIMIZE     (1L << 4)
#define MWM_FUNC_CLOSE        (1L << 5)

/* decorations */
#define MWM_DECOR_ALL         (1L << 0)
#define MWM_DECOR_BORDER      (1L << 1)
#define MWM_DECOR_RESIZEH     (1L << 2)
#define MWM_DECOR_TITLE       (1L << 3)
#define MWM_DECOR_MENU        (1L << 4)
#define MWM_DECOR_MINIMIZE    (1L << 5)
#define MWM_DECOR_MAXIMIZE    (1L << 6)



//Actually it is a singleton

@interface EWMHService : NSObject
{

}

@property (strong, nonatomic) NSArray *atoms;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBAtomService *atomService;


// Root window properties (some are also messages too)
@property (strong, nonatomic)NSString* EWMHSupported;
@property (strong, nonatomic)NSString* EWMHClientList;
@property (strong, nonatomic)NSString* EWMHClientListStacking;
@property (strong, nonatomic)NSString* EWMHNumberOfDesktops;
@property (strong, nonatomic)NSString* EWMHDesktopGeometry;
@property (strong, nonatomic)NSString* EWMHDesktopViewport;
@property (strong, nonatomic)NSString* EWMHCurrentDesktop;
@property (strong, nonatomic)NSString* EWMHDesktopNames;
@property (strong, nonatomic)NSString* EWMHActiveWindow;
@property (strong, nonatomic)NSString* EWMHWorkarea;
@property (strong, nonatomic)NSString* EWMHSupportingWMCheck;
@property (strong, nonatomic)NSString* EWMHVirtualRoots;
@property (strong, nonatomic)NSString* EWMHDesktopLayout;
@property (strong, nonatomic)NSString* EWMHShowingDesktop;

// Root Window Messages
@property (strong, nonatomic)NSString* EWMHCloseWindow;
@property (strong, nonatomic)NSString* EWMHMoveresizeWindow;
@property (strong, nonatomic)NSString* EWMHWMMoveresize;
@property (strong, nonatomic)NSString* EWMHRestackWindow;
@property (strong, nonatomic)NSString* EWMHRequestFrameExtents;

// Application window properties
@property (strong, nonatomic)NSString* EWMHWMName;
@property (strong, nonatomic)NSString* EWMHWMVisibleName;
@property (strong, nonatomic)NSString* EWMHWMIconName;
@property (strong, nonatomic)NSString* EWMHWMVisibleIconName;
@property (strong, nonatomic)NSString* EWMHWMDesktop;
@property (strong, nonatomic)NSString* EWMHWMWindowType;
@property (strong, nonatomic)NSString* EWMHWMState;
@property (strong, nonatomic)NSString* EWMHWMAllowedActions;
@property (strong, nonatomic)NSString* EWMHWMStrut;
@property (strong, nonatomic)NSString* EWMHWMStrutPartial;
@property (strong, nonatomic)NSString* EWMHWMIconGeometry;
@property (strong, nonatomic)NSString* EWMHWMIcon;
@property (strong, nonatomic)NSString* EWMHWMPid;
@property (strong, nonatomic)NSString* EWMHWMHandledIcons;
@property (strong, nonatomic)NSString* EWMHWMUserTime;
@property (strong, nonatomic)NSString* EWMHWMUserTimeWindow;
@property (strong, nonatomic)NSString* EWMHWMFrameExtents;

// The window types (used with EWMH_WMWindowType)
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDesktop;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDock;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeToolbar;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeMenu;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeUtility;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeSplash;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDialog;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDropdownMenu;
@property (strong, nonatomic)NSString* EWMHWMWindowTypePopupMenu;

@property (strong, nonatomic)NSString* EWMHWMWindowTypeTooltip;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeNotification;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeCombo;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDnd;

@property (strong, nonatomic)NSString* EWMHWMWindowTypeNormal;

// The application window states (used with EWMH_WMWindowState)
@property (strong, nonatomic)NSString* EWMHWMStateModal;
@property (strong, nonatomic)NSString* EWMHWMStateSticky;
@property (strong, nonatomic)NSString* EWMHWMStateMaximizedVert;
@property (strong, nonatomic)NSString* EWMHWMStateMaximizedHorz;
@property (strong, nonatomic)NSString* EWMHWMStateShaded;
@property (strong, nonatomic)NSString* EWMHWMStateSkipTaskbar;
@property (strong, nonatomic)NSString* EWMHWMStateSkipPager;
@property (strong, nonatomic)NSString* EWMHWMStateHidden;
@property (strong, nonatomic)NSString* EWMHWMStateFullscreen;
@property (strong, nonatomic)NSString* EWMHWMStateAbove;
@property (strong, nonatomic)NSString* EWMHWMStateBelow;
@property (strong, nonatomic)NSString* EWMHWMStateDemandsAttention;

// The application window allowed actions (used with EWMH_WMAllowedActions)
@property (strong, nonatomic)NSString* EWMHWMActionMove;
@property (strong, nonatomic)NSString* EWMHWMActionResize;
@property (strong, nonatomic)NSString* EWMHWMActionMinimize;
@property (strong, nonatomic)NSString* EWMHWMActionShade;
@property (strong, nonatomic)NSString* EWMHWMActionStick;
@property (strong, nonatomic)NSString* EWMHWMActionMaximizeHorz;
@property (strong, nonatomic)NSString* EWMHWMActionMaximizeVert;
@property (strong, nonatomic)NSString* EWMHWMActionFullscreen;
@property (strong, nonatomic)NSString* EWMHWMActionChangeDesktop;
@property (strong, nonatomic)NSString* EWMHWMActionClose;
@property (strong, nonatomic)NSString* EWMHWMActionAbove;
@property (strong, nonatomic)NSString* EWMHWMActionBelow;

// Window Manager Protocols
@property (strong, nonatomic)NSString* EWMHWMPing;
@property (strong, nonatomic)NSString* EWMHWMSyncRequest;
@property (strong, nonatomic)NSString* EWMHWMFullscreenMonitors;

// Other properties
@property (strong, nonatomic)NSString* EWMHWMFullPlacement;
@property (strong, nonatomic)NSString* UTF8_STRING;
@property (strong, nonatomic)NSString* MANAGER;
@property (strong, nonatomic)NSString* KdeNetWFrameStrut;
@property (strong, nonatomic)NSString* MotifWMHints;

//GNUstep properties
@property (strong, nonatomic)NSString *GNUStepMiniaturizeWindow;
@property (strong, nonatomic)NSString *GNUStepHideApp;
@property (strong, nonatomic)NSString *GNUStepWmAttr;
@property (strong, nonatomic)NSString *GNUStepTitleBarState;
@property (strong, nonatomic)NSString *GNUStepFrameOffset;

//Added EWMH properties

@property (strong, nonatomic)NSString *EWMHStartupId;
@property (strong, nonatomic)NSString *EWMHFrameExtents;
@property (strong, nonatomic)NSString *EWMHStrutPartial;
@property (strong, nonatomic)NSString *EWMHVisibleIconName;


+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection;

- (id) initWithConnection:(XCBConnection*)aConnection;

- (void) putPropertiesForRootWindow:(XCBWindow*) rootWindow andWmWindow:(XCBWindow*) wmWindow;

- (void) changePropertiesForWindow:(XCBWindow*) aWindow
                          withMode:(uint8_t) mode
                      withProperty:(NSString*) propertyKey
                          withType:(xcb_atom_t) type
                        withFormat:(uint8_t) format
                    withDataLength:(uint32_t) dataLength
                          withData:(const void *) data;

- (void *) getProperty:(NSString*) aPropertyName
          propertyType:(xcb_atom_t) propertyType
             forWindow:(XCBWindow*)aWindow
                delete:(BOOL)deleteProperty
                length:(uint32_t)len;

- (void) updateNetFrameExtentsForWindow:(XCBWindow*)aWindow;
- (void) updateNetFrameExtentsForWindow:(XCBWindow*)aWindow andExtents:(uint32_t[])extents;
- (void) updateNetWmWindowTypeDockForWindow:(XCBWindow*)aWindow;
- (BOOL) ewmhClientMessage:(NSString*)anAtomMessageName;
- (void) handleClientMessage:(NSString*)anAtomMessageName forWindow:(XCBWindow*)aWindow data:(xcb_client_message_data_t)someData;
- (xcb_get_property_reply_t *) netWmIconFromWindow:(XCBWindow*)aWindow;
- (void) updateNetClientList;
- (void) updateNetActiveWindow:(XCBWindow*)aWindow;
- (void) updateNetSupported:(NSArray*)atomsArray forRootWindow:(XCBWindow*)aRootWindow;
- (void) updateNetWmState:(XCBWindow*) aWindow;
- (uint32_t) netWMPidForWindow:(XCBWindow *)aWindow;

- (void) dealloc;

@end
