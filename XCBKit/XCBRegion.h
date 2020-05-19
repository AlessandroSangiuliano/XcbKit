//
//  XCBRegion.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 30/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

/** This class uses the xcb_xfixes that implements the XFixes protocol **/


#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#import <xcb/xfixes.h>

@interface XCBRegion : NSObject
{
    NSString* className;
}

@property (nonatomic) xcb_xfixes_region_t regionId;
@property (strong, nonatomic) XCBConnection* connection;
@property (nonatomic) int rectanglesNumber;
@property (nonatomic) xcb_rectangle_t* rectangles;

- (id) initWithConnection:(XCBConnection*)aConnection;
- (id) initWithConnection:(XCBConnection *)aConnection regionId:(xcb_xfixes_region_t)aRegionId;
- (id) initWithConnection:(XCBConnection *)aConnection rectagles:(xcb_rectangle_t*)rects count:(int) rectsNumber;
- (void) unionWithRegion:(XCBRegion*)secondSource destination:(XCBRegion*)destination;
- (BOOL) initXFixesProtocol;


@end
