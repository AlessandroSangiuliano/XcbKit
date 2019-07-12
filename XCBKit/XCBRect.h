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
	XCBPoint *point;
	XCBSize *size;
}

+ (XCBRect*) rectFromXcbRectangle:(xcb_rectangle_t) rect;

- (id) initWithPoint:(XCBPoint *) aPoint andSize:(XCBSize*) aSize;
- (void) setSize:(XCBSize*) aSize;
- (XCBSize*) size;
- (void) setPoint:(XCBPoint*) aPoint;
- (XCBPoint*) point;
- (NSString *) description;
@end
