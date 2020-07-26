//
//  XCBKitTests.m
//  XCBKitTests
//
//  Created by alex on 26/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBConnectionTests.h"
#import "XCBConnection.h"
#import "EWMHService.h"
#import "CairoDrawer.h"
#import "XCBFrame.h"
#import "XCBCreateWindowTypeRequest.h"
#import "XCBTitleBar.h"

@implementation XCBConnectionTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testConnection
{
    XCBConnection *connection = [[XCBConnection alloc] init];
    STAssertNotNil(connection, @"NIL");
	[connection closeConnection];
}

- (void) testConnectionWithDisplay
{
    XCBConnection *connection = [[XCBConnection alloc] initWithDisplay:@":0"];
    STAssertNotNil(connection, @"NIL");
	[connection closeConnection];
}

- (void) testRegisterWindow
{
	xcb_window_t window = 0;
	XCBWindow *aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	
    XCBConnection *connection = [[XCBConnection alloc] init];
	[connection registerWindow:aWindow];
	NSMutableDictionary *windowsMap = [connection windowsMap];
	unsigned long count = (unsigned long)[windowsMap count];
	NSLog(@"Size: %lu", count);
	STAssertEquals(count, (unsigned long)2, @"Expected 1");
	[connection closeConnection];
}

- (void) testWindowForXCBId
{
	XCBConnection *connection = [[XCBConnection alloc] init];
	
	/** register windows with id 0 **/
	
	xcb_window_t window = 500;
	XCBWindow *aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	[connection registerWindow:aWindow];
	
	/** register windows with id 1 **/
	
	window = 1;
	aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	[connection registerWindow:aWindow];
	
	XCBWindow *windowFromMap = [connection windowForXCBId:500];
	
	NSMutableDictionary *windowsMap = [connection windowsMap];
	unsigned long count = (unsigned long)[windowsMap count];
	NSLog(@"Size: %lu", count);
	
	NSLog(@"Window ID: %u", [windowFromMap window]);
    
	STAssertEquals([windowFromMap window],(xcb_window_t)500, @"Expected: 1");
	[connection closeConnection];
}

- (void) testUnregisterWindow
{
	xcb_window_t window = 500;
	XCBWindow *aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	
    XCBConnection *connection = [[XCBConnection alloc] init];
	[connection registerWindow:aWindow];
	
	[connection unregisterWindow:aWindow];
	NSMutableDictionary *windowsMap = [connection windowsMap];
	
	unsigned long count = (unsigned long)[windowsMap count];
	NSLog(@"Size: %lu", count);
    //XCBWindow *retrieved = [connection windowForXCBId:window];
	STAssertEquals(count, (unsigned long)1, @"Expected 01");
	[connection closeConnection];
    
    
}

- (void) testRootWindowSubStructureRedirect
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    [connection flush];
    XCBWindow *rootWindow = [[XCBWindow alloc] initWithXCBWindow:[screen screen]->root andConnection:connection];
    
    XCBReply* reply = [connection getAttributesForWindow:rootWindow];
    xcb_get_window_attributes_reply_t* rep = [reply reply];
    NSLog(@"All events: %u", rep->all_event_masks);
    NSLog(@"Redirect: %u", XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT);
    NSLog(@"Notify: %u", XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY);
    pause();
    
    free(rep);
    reply = nil;
}

- (void) testChangeAttributes
{
    XCBConnection *connection = [[XCBConnection alloc] init];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    XCBPoint coordinates = XCBMakePoint(1, 1);
    XCBSize sizes = XCBMakeSize(300, 300);
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
    XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBWindow *window = [connection createWindowWithDepth:[screen screen]->root_depth
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:coordinates.x
                                            withYPosition:coordinates.y
                                                withWidth:sizes.width
                                               withHeight:sizes.height
                                         withBorrderWidth:1
                                             withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                             withVisualId:visual
                                            withValueMask:mask
                                            withValueList:values];
    
    mask = XCB_CW_OVERRIDE_REDIRECT;
    uint32_t overraideValue[1] = {YES};
    
    [connection changeAttributes:overraideValue forWindow:window withMask:mask checked:NO];
    
    XCBReply *reply = [connection getAttributesForWindow:window];
    xcb_get_window_attributes_reply_t *rep = [reply reply];
    
    STAssertTrue(rep->override_redirect == YES, @"");
    free(rep);
    reply = nil;
}

- (void) testCreateWindow
{
	XCBConnection *connection = [[XCBConnection alloc] init];
	XCBScreen *screen = [[connection screens] objectAtIndex:0];
	XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
	XCBWindow *window = [connection createWindowWithDepth: XCB_COPY_FROM_PARENT
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:0
                                            withYPosition:0
                                                withWidth:150
                                               withHeight:22 //altezza finestra di decorazione
                                         withBorrderWidth:10
                                             withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                             withVisualId:rootVisual
                                            withValueMask:0
                                            withValueList:NULL];
    
    [connection mapWindow:window];
    [connection flush];
	
	pause();
}

- (void) testHandleMapNotify
{
	XCBConnection *connection = [[XCBConnection alloc] init];
	XCBScreen *screen = [[connection screens] objectAtIndex:0];
	XCBWindow *rootWindow = [screen rootWindow];
	xcb_map_notify_event_t anEvent;
	anEvent.window = [rootWindow window];
	[connection handleMapNotify:&anEvent];
}

- (void) testHandleButtonPress
{
    XCBConnection *connection = [[XCBConnection alloc] init];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    XCBPoint coordinates = XCBMakePoint(1, 1);
    XCBSize sizes = XCBMakeSize(300, 300);
    
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
    XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBWindow *window = [connection createWindowWithDepth:[screen screen]->root_depth
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:coordinates.x
                                            withYPosition:coordinates.y
                                                withWidth:sizes.width
                                               withHeight:sizes.height
                                         withBorrderWidth:1
                                             withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                             withVisualId:visual
                                            withValueMask:mask
                                            withValueList:values];
    
    XCBWindow *subWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                            withParentWindow:window
                                               withXPosition:10
                                               withYPosition:10
                                                   withWidth:20
                                                  withHeight:20
                                            withBorrderWidth:5
                                                withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                withVisualId:visual
                                               withValueMask:0
                                               withValueList:NULL];
    
    
    [connection mapWindow:window];
    [connection mapWindow:subWindow];
    [connection flush];
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
                //[connection mapWindow:window];
                //[connection flush];
                NSLog(@"Expose");
                break;
                
            case XCB_MOTION_NOTIFY:
                [connection handleMotionNotify:(xcb_motion_notify_event_t *)e];
                [connection flush];
                break;
                
            case XCB_BUTTON_PRESS:
                [connection handleButtonPress:(xcb_button_press_event_t*)e];
                break;
                
            case XCB_MAP_NOTIFY:
                NSLog(@"MAP NOTIFY");
                break;
            default:
                break;
        }
        free(e);
    }
    
    
}

- (void) testSimpleWindow
{
    XCBConnection *connection = [[XCBConnection alloc] init];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    XCBPoint coordinates = XCBMakePoint(1, 1);
    XCBSize sizes = XCBMakeSize(300, 300);
    
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
    XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBWindow *window = [connection createWindowWithDepth:[screen screen]->root_depth
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:coordinates.x
                                            withYPosition:coordinates.y
                                                withWidth:sizes.width
                                               withHeight:sizes.height
                                         withBorrderWidth:1
                                             withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                             withVisualId:visual
                                            withValueMask:mask
                                            withValueList:values];
    
    [connection mapWindow:window];
    [connection flush];
    
    pause();
}

- (void) testHandleEvents
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW | XCB_EVENT_MASK_LEAVE_WINDOW | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBPoint coordinates = XCBMakePoint(1, 1);
    XCBSize sizes = XCBMakeSize(300, 300);
    
    
    XCBWindow *clientWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                               withParentWindow:[screen rootWindow]
                                                  withXPosition:coordinates.x
                                                  withYPosition:coordinates.y
                                                      withWidth:sizes.width
                                                     withHeight:sizes.height
                                               withBorrderWidth:1
                                                   withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                   withVisualId:visual
                                                  withValueMask:mask
                                                  withValueList:values];
    
    XCBWindow* selectionManagerWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                                         withParentWindow:[screen rootWindow]
                                                            withXPosition:-1
                                                            withYPosition:-1
                                                                withWidth:1
                                                               withHeight:1
                                                         withBorrderWidth:0
                                                             withXCBClass:XCB_COPY_FROM_PARENT
                                                             withVisualId:visual
                                                            withValueMask:0
                                                            withValueList:NULL];
    
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    [connection registerAsWindowManager:YES screenId:1 selectionWindow:selectionManagerWindow];
    [ewmhService putPropertiesForRootWindow:[screen rootWindow] andWmWindow:selectionManagerWindow];
    
    xcb_atom_t type = [[[[ewmhService atomService] cachedAtoms] objectForKey:[ewmhService UTF8_STRING]] unsignedIntValue];
    
    [ewmhService changePropertiesForWindow:clientWindow
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:[ewmhService EWMHWMName]
                                  withType:type
                                withFormat:8
                            withDataLength:4
                                  withData:"Pova"];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:clientWindow visual:visual];
    
    //[connection mapWindow:clientWindow];
    [connection flush];
    
    [self eventLoopWithConnection:connection andDrawer:drawer andClientWindow:clientWindow];
    
    //pause();
    
    clientWindow = nil;
    selectionManagerWindow = nil;
    screen = nil;
    visual = nil;
    connection = nil;
    ewmhService = nil;
    drawer = nil;
}

- (void) eventLoopWithConnection:(XCBConnection*)connection
                       andDrawer:(CairoDrawer*) drawer
                 andClientWindow:(XCBWindow*)clientWindow
{
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
                NSLog(@"");
                xcb_expose_event_t * exposeEvent = (xcb_expose_event_t *)e;
                NSLog(@"Expose for window %u", exposeEvent->window);
                [connection handleExpose:exposeEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_MOTION_NOTIFY:
                NSLog(@"");
                xcb_motion_notify_event_t *motionEvent = (xcb_motion_notify_event_t *)e;
                //NSLog(@"Motion Notify for window %u: ", motionEvent->event);
                [connection handleMotionNotify:motionEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_ENTER_NOTIFY:
                NSLog(@"");
                xcb_enter_notify_event_t* enterEvent = (xcb_enter_notify_event_t*)e;
                NSLog(@"Enter notify for window %u", enterEvent->event);
                [connection handleEnterNotify:enterEvent];
                [connection flush];
                break;
                
            case XCB_LEAVE_NOTIFY:
                NSLog(@"");
                xcb_leave_notify_event_t* leaveEvent = (xcb_leave_notify_event_t*)e;
                NSLog(@"Leave notify for window %u", leaveEvent->event);
                [connection handleLeaveNotify:leaveEvent];
                [connection flush];
                break;
                
            case XCB_FOCUS_IN:
                NSLog(@"");
                xcb_focus_in_event_t* focusInEvent = (xcb_focus_in_event_t*)e;
                NSLog(@"Focus In Event for window %u", focusInEvent->event);
                //[connection handleFocusIn:focusInEvent];
                break;
                
            case XCB_FOCUS_OUT:
                NSLog(@"");
                xcb_focus_out_event_t* focusOutEvent = (xcb_focus_out_event_t*)e;
                NSLog(@"Focus Out Event for window %u", focusOutEvent->event);
                //[connection handleFocusOut:focusOutEvent];
                break;
                
            case XCB_VISIBILITY_NOTIFY:
                NSLog(@"");
                xcb_visibility_notify_event_t* visibilityEvent = (xcb_visibility_notify_event_t*)e;
                NSLog(@"Enter notify for window %u", visibilityEvent->window);
                [connection handleVisibilityEvent:visibilityEvent];
                break;
                
            case XCB_BUTTON_PRESS:
                NSLog(@"");
                xcb_button_press_event_t* pressEvent = (xcb_button_press_event_t*)e;
                NSLog(@"Button Press Event for window %u: ", pressEvent->event);
                [connection handleButtonPress:pressEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_BUTTON_RELEASE:
                NSLog(@"");
                xcb_button_release_event_t* releaseEvent = (xcb_button_release_event_t*)e;
                NSLog(@"Button Release Event for window %u: ", releaseEvent->event);
                [connection handleButtonRelease:releaseEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_MAP_NOTIFY:
                NSLog(@"");
                xcb_map_notify_event_t *notifyEvent = (xcb_map_notify_event_t*)e;
                NSLog(@"MAP NOTIFY for window %u", notifyEvent->window);
                [connection handleMapNotify:notifyEvent];
                break;
                
            case XCB_MAP_REQUEST:
                NSLog(@"");
                xcb_map_request_event_t* mapRequestEvent = (xcb_map_request_event_t*)e;
                NSLog(@"Map Request for window %u", mapRequestEvent->window);
                [connection handleMapRequest:mapRequestEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_UNMAP_NOTIFY:
                NSLog(@"");
                xcb_unmap_notify_event_t* unmapNotifyEvent = (xcb_unmap_notify_event_t*)e;
                NSLog(@"Unmap Notify for window %u", unmapNotifyEvent->window);
                [connection handleUnMapNotify:unmapNotifyEvent];
                break;
                
            case XCB_DESTROY_NOTIFY:
                NSLog(@"");
                xcb_destroy_notify_event_t *destroyNotify = (xcb_destroy_notify_event_t*)e;
                NSLog(@"Destroy Notify for window: %u", destroyNotify->window);
                [connection handleDestroyNotify:destroyNotify];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_CLIENT_MESSAGE:
                NSLog(@"");
                xcb_client_message_event_t *clientMessageEvent = (xcb_client_message_event_t *)e;
                NSLog(@"Cient message event: %u", clientMessageEvent->window);
                [connection handleClientMessage:clientMessageEvent];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
                
            case XCB_CONFIGURE_REQUEST:
                NSLog(@"");
                xcb_configure_request_event_t* configRequest = (xcb_configure_request_event_t*)e;
                NSLog(@"Configure request for window %u", configRequest->window);
                [connection handleConfigureWindowRequest:configRequest];
                [connection flush];
                [connection setNeedFlush:NO];
                break;
            case XCB_PROPERTY_NOTIFY:
                NSLog(@"");
                xcb_property_notify_event_t* propEvent = (xcb_property_notify_event_t*)e;
                NSLog(@"Window %u notify property change", propEvent->window);
                break;
            default:
                break;
        }
        free(e);
    }
    
}

- (void) testKindOfClass
{
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] initWithCapacity:1000];
    
    XCBWindow* window = [[XCBWindow alloc] initWithXCBWindow:1 andConnection:nil];
    XCBFrame* frame = [[XCBFrame alloc] initWithXCBWindow:2 andConnection:nil];
    
    [dictionary setObject:window forKey:[NSNumber numberWithInt:1]];
    [dictionary setObject:frame forKey:[NSNumber numberWithInt:2]];
    
    XCBWindow *windowFromDict;
    XCBFrame *frameFromDict;
    
    if ([[dictionary objectForKey:[NSNumber numberWithInt:2]] isKindOfClass:[XCBWindow class]])
    {
        windowFromDict = [dictionary objectForKey:[NSNumber numberWithInt:1]];
        NSLog(@"The object is a XCBWindow: %u", [windowFromDict window]);
    }
    else
        NSLog(@"The window is not a XCBWindow");
    
    if ([[dictionary objectForKey:[NSNumber numberWithInt:1]] isKindOfClass:[XCBFrame class]])
    {
        frameFromDict = [dictionary objectForKey:[NSNumber numberWithInt:2]];
        NSLog(@"The object is a XCBWindow: %u", [frameFromDict window]);
    }
    else
        NSLog(@"The window is not a XCBFrame");
    
    windowFromDict = [dictionary objectForKey:[NSNumber numberWithInt:2]];
    
    if ([windowFromDict respondsToSelector:@selector(childWindowForKey:)])
    {
        NSLog(@"funzica");
    }
    
}

- (void) testXCBCreateWindowRequest
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
    XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:10];
    [request setHeight:300];
    [request setWidth:150];
    [request setXPosition:0];
    [request setYPosition:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueList:values];
    [request setValueMask:mask];
    [request setVisual:visual];
    
    XCBWindowTypeResponse* response = [connection createWindowForRequest:request registerWindow:YES];
    request = nil;
    
    STAssertTrue([[response window] isKindOfClass:[XCBWindow class]], @"Expected XCBWindow");
    
    request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBFrameRequest];
    
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:10];
    [request setHeight:300];
    [request setWidth:150];
    [request setXPosition:0];
    [request setYPosition:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueList:values];
    [request setValueMask:mask];
    [request setVisual:visual];
    
    response = [connection createWindowForRequest:request registerWindow:YES];
    request = nil;
    
    STAssertTrue([[response frame] isKindOfClass:[XCBFrame class]], @"Expected XCBFrame");
    
    request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBTitleBarRequest];
    
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:10];
    [request setHeight:300];
    [request setWidth:150];
    [request setXPosition:0];
    [request setYPosition:0];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setValueList:values];
    [request setValueMask:mask];
    [request setVisual:visual];
    
    response = [connection createWindowForRequest:request registerWindow:YES];
    request = nil;
    
    STAssertTrue([[response titleBar] isKindOfClass:[XCBTitleBar class]], @"Expected XCBTitleBar");
    
    response = nil;
    
}


@end
