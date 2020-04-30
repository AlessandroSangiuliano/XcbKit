//
//  XCBRegion.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 30/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//


#import "XCBRegion.h"


@implementation XCBRegion

@synthesize regionId;
@synthesize connection;
@synthesize rectanglesNumber;
@synthesize rectangles;


- (id) initWithConnection:(XCBConnection *)aConnection
{
    return [self initWithConnection:aConnection regionId:XCB_NONE];
}

- (id) initWithConnection:(XCBConnection *)aConnection regionId:(xcb_xfixes_region_t)aRegionId
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init");
        return nil;
    }
    
    connection = aConnection;
    className = NSStringFromClass([self class]);
    
    if (aRegionId == XCB_NONE)
        regionId = xcb_generate_id([connection connection]);
    else
        regionId = aRegionId;
    
    return self;

}

- (id) initWithConnection:(XCBConnection *)aConnection rectagles:(xcb_rectangle_t *)rects count:(int)rectsNumber
{
    self = [self initWithConnection:aConnection];
    
    rectanglesNumber = rectsNumber;
    rectangles = rects;
    
    xcb_xfixes_create_region([connection connection],
                             regionId,
                             rectanglesNumber,
                             rectangles);
    
    return self;
}

- (void) unionWithRegion:(XCBRegion *)secondSource destination:(XCBRegion *)destination
{
    if (regionId == XCB_NONE)
    {
        NSLog(@" [%@:] First source has no region id", className);
        return;
    }
    
    xcb_xfixes_union_region([connection connection], [self regionId], [secondSource regionId], [destination regionId]);
    
    return;
}

- (void) dealloc
{
    xcb_xfixes_destroy_region([connection connection], regionId);
    connection = nil;
    className = nil;
}

@end
