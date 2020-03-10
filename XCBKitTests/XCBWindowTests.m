//
//  XCBWindowTests.m
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBWindowTests.h"
#import "XCBWindow.h"
#import "XCBConnection.h"
#import "XCBCreateWindowTypeRequest.h"
#import "XCBWindowTypeResponse.h"
#import "XCBVisual.h"
#import "CairoDrawer.h"

@implementation XCBWindowTests

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

- (void) testWindowIdStringValue
{
	xcb_window_t window = 1;
	XCBWindow * aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	
	NSString *stringId = [aWindow windowIdStringValue];
	NSString *testCompare = [NSString stringWithFormat:@"%u", 1];
	STAssertEquals(stringId, testCompare, @"Expected id: 1");
}

- (void) testSetBorderWidth
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:XCB_NONE];
    [request setValueList:NULL];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    [connection mapWindow:window];
    [connection flush];
    
    [window setWindowBorderWidth:10];
    [connection flush];
    
    pause();
}

- (void) testTakeScreenshot
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    
    CairoDrawer* drawer = [[CairoDrawer alloc] initWithConnection:connection window:window visual:visual];
    
    request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:100];
    [request setYPosition:100];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];

    reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window2 = [reply window];

    

    [connection mapWindow:window];
    [connection mapWindow:window2];
    [connection flush];
    
    //[drawer takeScreenShot];
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
            {
                NSLog(@"Expose");
                [drawer drawText:@"AISSALARAISS" withColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1]];
                [drawer makePreviewImage];
                [drawer setWindow:window2];
                [drawer setPreviewImage];
                [connection flush];
                break;
            }
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

    pause();
    
}

@end
