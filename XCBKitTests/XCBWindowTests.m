//
//  XCBWindowTests.m
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBWindowTests.h"
#import "XCBWindow.h"

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

@end
