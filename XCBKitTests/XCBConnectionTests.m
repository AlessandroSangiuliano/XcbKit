//
//  XCBKitTests.m
//  XCBKitTests
//
//  Created by alex on 26/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBConnectionTests.h"
#import "XCBConnection.h"

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
    
    XCBPoint *coordinates = [[XCBPoint alloc] initWithX:1 andY:1];
    XCBSize *sizes = [[XCBSize alloc] initWithWidht:300 andHeight:300];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
                XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
                XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBWindow *window = [connection createWindowWithDepth:[screen screen]->root_depth
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:[coordinates getX]
                                            withYPosition:[coordinates getY]
                                                withWidth:[sizes getWidth]
                                               withHeight:[sizes getHeight]
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
                [connection handleMotionNotify:(xcb_motion_notify_event_t *)e forWindow:window];
                [connection flush];
                break;
                
            case XCB_BUTTON_PRESS:
                [connection handleButtonPress:(xcb_button_press_event_t*)e forWindow:window];
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
    
    XCBPoint *coordinates = [[XCBPoint alloc] initWithX:1 andY:1];
    XCBSize *sizes = [[XCBSize alloc] initWithWidht:300 andHeight:300];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   |
    XCB_EVENT_MASK_KEY_PRESS;
    
    
    XCBWindow *window = [connection createWindowWithDepth:[screen screen]->root_depth
                                         withParentWindow:[screen rootWindow]
                                            withXPosition:[coordinates getX]
                                            withYPosition:[coordinates getY]
                                                withWidth:[sizes getWidth]
                                               withHeight:[sizes getHeight]
                                         withBorrderWidth:1
                                             withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                             withVisualId:visual
                                            withValueMask:mask
                                            withValueList:values];
    
    [connection mapWindow:window];
    [connection flush];
    
    pause();
}


@end
