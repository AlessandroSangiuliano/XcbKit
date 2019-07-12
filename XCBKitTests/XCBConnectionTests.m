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
	NSMapTable *windowsMap = [connection windowsMap];
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
	
	NSMapTable *windowsMap = [connection windowsMap];
	unsigned long count = (unsigned long)[windowsMap count];
	NSLog(@"Size: %lu", count);
	
	NSLog(@"Window ID: %u", [windowFromMap window]);

	STAssertEquals([windowFromMap window],(xcb_window_t)500, @"Expected: 1");
	[connection closeConnection];
}

- (void) testUnregisterWindow
{
	xcb_window_t window = 0;
	XCBWindow *aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	
    XCBConnection *connection = [[XCBConnection alloc] init];
	[connection registerWindow:aWindow];
	
	[connection unregisterWindow:aWindow];
	NSMapTable *windowsMap = [connection windowsMap];
	
	unsigned long count = (unsigned long)[windowsMap count];
	NSLog(@"Size: %lu", count);
	STAssertEquals(count, (unsigned long)0, @"Expected 0");
	[connection closeConnection];


}

- (void) testCreateWindow
{
	XCBConnection *connection = [[XCBConnection alloc] init];
	XCBScreen *screen = [[connection screens] objectAtIndex:0];
	XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen].root_visual];
	[connection createWindowWithDepth: XCB_COPY_FROM_PARENT
					 withParentWindow:[screen rootWindow]
						withXPosition:0
						withYPosition:0
							withWidth:150
						   withHeight:150
					 withBorrderWidth:10
						 withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
						 withVisualId:rootVisual
						withValueMask:0
						withValueList:NULL];
	
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

@end
