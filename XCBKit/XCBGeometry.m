//
//  XCBGeometry.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 24/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBGeometry.h"
#import "XCBWindow.h"

@implementation XCBGeometry

@synthesize rect;
@synthesize borderWidth;
@synthesize depth;
@synthesize rootWindow;

- (id) init
{
    return [self initWithGeometryReply:NULL];
}

- (id) initWithGeometryReply:(xcb_get_geometry_reply_t *)aReplay
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    rect = XCBMakeRect(XCBMakePoint(aReplay->x, aReplay->y), XCBMakeSize(aReplay->width, aReplay->height));
    borderWidth = aReplay->border_width;
    depth = aReplay->depth;
    rootWindow = [[XCBWindow alloc] initWithXCBWindow:aReplay->root andConnection:nil];
    
    return self;
}

- (void) description
{
    NSLog(@"Geometries:\n%@;\nBorder width: %d;\nDepth: %d;\nRoot Window: %d;",
          FnFromXCBRectToString(rect),
          borderWidth,
          depth,
          [rootWindow window]);
}

-(void) dealloc
{
    rootWindow = nil;
}


@end
