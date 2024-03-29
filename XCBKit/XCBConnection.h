//
//  XCBConnection.h
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBScreen.h"
#import "XCBVisual.h"
#import "utils/XCBCreateWindowTypeRequest.h"
#import "utils/XCBWindowTypeResponse.h"
#import "XCBReply.h"
#include <xcb/xcb.h>

#define FRAMEMASK   XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | \
                    XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_KEY_PRESS |\
                    XCB_EVENT_MASK_BUTTON_MOTION | XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY |\
                    XCB_EVENT_MASK_FOCUS_CHANGE | XCB_EVENT_MASK_ENTER_WINDOW | XCB_EVENT_MASK_LEAVE_WINDOW |\
                    XCB_EVENT_MASK_VISIBILITY_CHANGE | XCB_EVENT_MASK_PROPERTY_CHANGE | XCB_EVENT_MASK_POINTER_MOTION |       \
                    XCB_CW_CURSOR

#define CLIENTLISTSIZE 1000
#define WINDOWSMAPUPDATED @"windowsMapUpdated"

@class XCBWindow;
@class EWMHService;
@class XCBAtomService;
@class XCBRegion;

@interface XCBConnection : NSObject
{
    xcb_connection_t *connection;
    NSString *displayName;
    NSMutableDictionary *windowsMap;
	NSMutableArray *screens;
	BOOL needFlush;
    xcb_timestamp_t currentTime;
    xcb_window_t clientList[CLIENTLISTSIZE];
}

@property (nonatomic, assign) BOOL dragState;
@property (strong, nonatomic) XCBRegion* damagedRegions;
@property (nonatomic, assign) BOOL xfixesInitialized;
@property (nonatomic, assign) BOOL resizeState;
@property (nonatomic, assign) NSInteger clientListIndex;
@property (nonatomic, assign, readonly) BOOL isAWindowManager;
@property (nonatomic, assign) BOOL isWindowsMapUpdated;

+ (XCBConnection *) sharedConnectionAsWindowManager:(BOOL)asWindowManager;
- (xcb_connection_t *) connection;
/**
 * init with DISPLAY and screeen to NULL
 */
- (id) initAsWindowManager:(BOOL)isWindowManager;
- (id) initWithXcbConnection:(xcb_connection_t*)aConnection andDisplay:(NSString*)aDisplay asWindowManager:(BOOL)isWindowManager;
- (id) initWithDisplay:(NSString *) aDisplay asWindowManager:(BOOL)isWindowManager;
- (void) registerWindow:(XCBWindow*) aWindow;
- (void) unregisterWindow:(XCBWindow *) aWindow;
- (NSMutableDictionary *) windowsMap;
- (void) setWindowsMap:(NSMutableDictionary *)aWindowsMap;
- (void) closeConnection;
- (XCBWindow*) windowForXCBId:(xcb_window_t)anId;
- (int) flush;
- (void) setNeedFlush:(BOOL) aNeedFlushChoice;
- (XCBWindow *) createWindowWithDepth: (uint8_t) depth
			  withParentWindow: (XCBWindow *) aParentWindow
				 withXPosition: (int16_t) xPosition
				 withYPosition: (int16_t) yPosition
					 withWidth: (int16_t) width
					withHeight: (int16_t) height
			  withBorrderWidth: (uint16_t) borderWidth
				  withXCBClass: (uint16_t) xcbClass
				  withVisualId: (XCBVisual*) aVisual
				 withValueMask: (uint32_t) valueMask
				 withValueList: (const uint32_t *) valueList
                registerWindow:(BOOL)reg;

- (XCBWindowTypeResponse*) createWindowForRequest:(XCBCreateWindowTypeRequest*) aRequest registerWindow:(BOOL) reg;
- (void) checkScreens;
- (NSMutableArray*) screens;
- (void) grabServer;
- (void) ungrabServer;

/*** HANDLE EVENTS ***/

- (void) handleMapNotify: (xcb_map_notify_event_t*)anEvent;
- (void) handleUnMapNotify:(xcb_unmap_notify_event_t *) anEvent;
- (void) handleMapRequest: (xcb_map_request_event_t*)anEvent;
- (void) handleUnmapRequest:(xcb_unmap_window_request_t*)anEvent;
- (void) handleCreateNotify: (xcb_create_notify_event_t*)anEvent;
- (void) handleButtonPress: (xcb_button_press_event_t*)anEvent;
- (void) handleButtonRelease: (xcb_button_release_event_t*)anEvent;
- (void) handleKeyPress: (xcb_key_press_event_t*)anEvent;
- (void) handleKeyRelease: (xcb_key_release_event_t*)anEvent;
- (void) handleMotionNotify: (xcb_motion_notify_event_t*)anEvent;
- (void) handleEnterNotify: (xcb_enter_notify_event_t*)anEvent;
- (void) handleLeaveNotify: (xcb_leave_notify_event_t*)anEvent;
- (void) handleExpose: (xcb_expose_event_t*)anEvent;
- (void) handleCirculateRequest: (xcb_circulate_request_event_t*)anEvent;
- (void) handleConfigureWindowRequest: (xcb_configure_request_event_t*)anEvent;
- (void) handleConfigureNotify: (xcb_configure_notify_event_t*)anEvent;
- (void) handleReparentNotify: (xcb_reparent_notify_event_t*)anEvent;
- (void) handlePropertyNotify: (xcb_property_notify_event_t*)anEvent;
- (void) handleClientMessage: (xcb_client_message_event_t*)anEvent;
- (void) handleDestroyNotify: (xcb_destroy_notify_event_t*)anEvent;
- (void) handleFocusOut: (xcb_focus_out_event_t*)anEvent;
- (void) handleFocusIn: (xcb_focus_in_event_t*)anEvent;
- (void) handleVisibilityEvent: (xcb_visibility_notify_event_t*)anEvent;

/*** SENDS EVENTS ***/

- (void) sendEvent:(const char*)anEvent toClient:(XCBWindow*)aWindow propagate:(BOOL)propagating;

/*** DEAL WITH WINDOW STUFFS ***/

- (void) reparentWindow: (XCBWindow*) aWindow toWindow:(XCBWindow*)parentWindow position:(XCBPoint)position;
- (void) mapWindow: (XCBWindow*) aWindow;
- (void) unmapWindow:(XCBWindow*)aWindow;
- (void) addDamagedRegion:(XCBRegion*) damagedRegion;
- (void) borderClickedForFrameWindow:(XCBFrame*)aFrame withEvent:(xcb_button_press_event_t*)anEvent;
- (void)drawAllTitleBarsExcept:(XCBTitleBar *)aTitileBar;
- (BOOL) registerAsWindowManager:(BOOL)replace screenId:(uint32_t)screenId selectionWindow:(XCBWindow*)selectionWindow;

/*** ACCESSORS ***/

- (xcb_timestamp_t) currentTime;
- (void) setCurrentTime:(xcb_timestamp_t)time;
- (XCBWindow*) rootWindowForScreenNumber:(int)number;
- (xcb_window_t*) clientList;
@end
