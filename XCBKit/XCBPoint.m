//
//  XCBPoint.m
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBPoint.h"

@implementation XCBPoint

- (id) initWithX:(int16_t)xCoordinate andY:(int16_t)yCoordinate
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[%@] Error during initialization",  NSStringFromClass([XCBPoint class]));
		return nil;
	}
	
	x = xCoordinate;
	y = yCoordinate;
    
    values[0] = x;
    values[1] = y;
	
	return self;
}

- (void) setX:(int16_t)xCoordinate
{
	x = xCoordinate;
    values[0] = x;
}

- (int16_t) getX
{
	return x;
}

- (void) setY:(int16_t)yCoordinate
{
	y = yCoordinate;
    values[1] = y;
}

- (int16_t) getY
{
	return y;
}

- (uint32_t*) values
{
    return values;
}

- (void) setValues:(uint32_t *)theValues
{
    values[0] = theValues[0];
    values[1] = theValues[1];
}

- (void) dealloc
{
    x = 0;
    y = 0;
    
    // TODO check memoria su values essendo un array vedere come liberarlo
}

@end
