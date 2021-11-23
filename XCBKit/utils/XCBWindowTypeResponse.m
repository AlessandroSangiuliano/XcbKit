//
//  XCBWindowTypeResponse.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 18/02/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBWindowTypeResponse.h"

@implementation XCBWindowTypeResponse

@synthesize window;
@synthesize frame;
@synthesize titleBar;

- (id) init
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Error while initialization");
        return nil;
    }
    
    return self;
}

- (id) initWithXCBWindow:(XCBWindow *)aWindow
{
    self = [self init];
    
    window = aWindow;
    
    return self;
}

- (id) initWithXCBFrame:(XCBFrame *)aFrame
{
    self = [self init];
    
    frame = aFrame;
    
    return self;
}

- (id) initWithXCBTitleBar:(XCBTitleBar *)aTitlebar
{
    self = [self init];
    
    titleBar = aTitlebar;
    
    return self;
}

- (void) dealloc
{
    window = nil;
    frame = nil;
    titleBar = nil;
}

@end
