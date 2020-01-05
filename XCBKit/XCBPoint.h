//
//  XCBPoint.h
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCBPoint : NSObject
{
	int16_t x;
	int16_t y;
    uint32_t values[2];
}

- (id) initWithX:(int16_t) xCoordinate andY:(int16_t) yCoordinate;

- (void) setX:(int16_t) xCoordinate;
- (int16_t) getX;
- (void) setY:(int16_t) yCoordinate;
- (int16_t) getY;
- (uint32_t*) values;
- (void) setValues:(uint32_t*)theValues;

@end
