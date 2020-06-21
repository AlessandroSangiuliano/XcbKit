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
#import "enums/EMessage.h"
#include <xcb/xcb.h>

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
}

@property (nonatomic) BOOL dragState;
@property (strong, nonatomic) EWMHService* ewmhService;
@property (strong, nonatomic) XCBRegion* damagedRegions;
@property (nonatomic) BOOL xfixesInitialized;
@property (nonatomic) BOOL resizeState;

+ (XCBConnection *) sharedConnection;
- (xcb_connection_t *) connection;
/**
 * init with DISPLAY and screeen to NULL
 */
- (id) init;
- (id) initWithDisplay:(NSString *) aDisplay;
- (void) registerWindow:(XCBWindow*) aWindow;
- (void) unregisterWindow:(XCBWindow *) aWindow;
- (NSMutableDictionary *) windowsMap;
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
				 withValueList: (const uint32_t *) valueList;

- (XCBWindowTypeResponse*) createWindowForRequest:(XCBCreateWindowTypeRequest*) aRequest registerWindow:(BOOL) reg;

- (NSMutableArray*) screens;

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
- (void) handleReparentNotify: (xcb_reparent_notify_event_t*)anEvent;
- (void) handlePropertyNotify: (xcb_property_notify_event_t*)anEvent;
- (void) handleClientMessage: (xcb_client_message_event_t*)anEvent;
- (void) handleDestroyNotify: (xcb_destroy_notify_event_t*)anEvent;
- (void) handleFocusOut: (xcb_focus_out_event_t*)anEvent;
- (void) handleFocusIn: (xcb_focus_in_event_t*)anEvent;

/*** SENDS EVENTS ***/

- (void) sendClientMessageTo:(XCBWindow*) destination message:(Message) message;

/*** DEAL WITH WINDOW STUFFS ***/

- (void) reparentWindow: (XCBWindow*) aWindow toWindow:(XCBWindow*)parentWindow position:(XCBPoint)position;
- (void) mapWindow: (XCBWindow*) aWindow;
- (void) unmapWindow:(XCBWindow*)aWindow;
- (XCBWindow*) parentWindowForWindow:(XCBWindow*)aWindow;
- (XCBRect) geometryForWindow:(XCBWindow*)aWindow;
- (BOOL) changeAttributes:(uint32_t[])values forWindow:(XCBWindow*) aWindow withMask:(uint32_t)aMask checked:(BOOL)check;
- (xcb_get_window_attributes_reply_t*) getAttributesForWindow:(XCBWindow*)aWindow;
- (void) addDamagedRegion:(XCBRegion*) damagedRegion;
- (void) borderClickedForFrameWindow:(XCBFrame*)aFrame withEvent:(xcb_button_press_event_t*)anEvent;


- (xcb_timestamp_t) currentTime;
- (void) setCurrentTime:(xcb_timestamp_t)time;
- (void) registerAsWindowManager:(BOOL)replace screenId:(uint32_t)screenId selectionWindow:(XCBWindow*)selectionWindow;
- (XCBWindow*) rootWindowForScreenNumber:(int)number;

@end

/**
 * Shared global XCB connection.  Only one connection may exist per process.
 * This variable is invalid before the first call to XCBConnection
 * +sharedConnection.
 */
extern XCBConnection *XCBConn;
