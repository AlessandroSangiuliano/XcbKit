//
//  XCBCreateWindowTypeRequest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 18/02/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBCreateWindowTypeRequest.h"

@implementation XCBCreateWindowTypeRequest

@synthesize depth;
@synthesize parentWindow;
@synthesize xPosition;
@synthesize yPosition;
@synthesize width;
@synthesize height;
@synthesize borderWidth;
@synthesize xcbClass;
@synthesize visual;
@synthesize valueMask;
@synthesize valueList;
@synthesize windowType;
@synthesize clientWindow;

- (id) initForWindowType:(XCBWindowType)aWindowType
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Error while initialization");
        return nil;
    }
    
    windowType = aWindowType;
    
    return self;
    
}

- (void) dealloc
{
    parentWindow = nil;
    visual = nil;
    clientWindow = nil;
}

@end
