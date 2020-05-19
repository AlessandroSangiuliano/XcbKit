//
//  XCBRect.h
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xcb/xcb.h>
#import "XCBPoint.h"
#import "XCBSize.h"

@interface XCBRect : NSObject
{
	XCBPoint *position;
	XCBSize *size;
}

@property (strong, nonatomic) XCBPoint *offset;

+ (XCBRect*) rectFromXcbRectangle:(xcb_rectangle_t) rect;

- (id) initWithPosition:(XCBPoint *) aPoint andSize:(XCBSize*) aSize;
- (id) initWithExposeEvent:(xcb_expose_event_t*)anEvent;
- (void) setSize:(XCBSize*) aSize;
- (XCBSize*) size;
- (void) setPosition:(XCBPoint*) aPoint;
- (XCBPoint*) position;
- (NSString *) description;
- (xcb_rectangle_t) xcbRectangle;
@end
