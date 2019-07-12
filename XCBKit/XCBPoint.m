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
	
	return self;
}

- (void) setX:(int16_t)xCoordinate
{
	x = xCoordinate;
}

- (int16_t) getX
{
	return x;
}

- (void) setY:(int16_t)yCoordinate
{
	y = yCoordinate;
}

- (int16_t) getY
{
	return y;
}

@end
