//
//  XCBGeometry.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 24/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBGeometryReply.h"
#import "XCBWindow.h"

@implementation XCBGeometryReply

@synthesize rect;
@synthesize borderWidth;
@synthesize depth;
@synthesize rootWindow;
@synthesize geometryReply;

- (id) initWithGeometryReply:(xcb_get_geometry_reply_t *)aReplay
{
    self = [super initWithReply:aReplay];
    
    if (self == nil)
        return nil;

    rect = XCBMakeRect(XCBMakePoint(aReplay->x, aReplay->y), XCBMakeSize(aReplay->width, aReplay->height));
    borderWidth = aReplay->border_width;
    depth = aReplay->depth;
    rootWindow = [[XCBWindow alloc] initWithXCBWindow:aReplay->root andConnection:nil];
    geometryReply = aReplay;
    
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
    geometryReply = NULL;
}


@end
