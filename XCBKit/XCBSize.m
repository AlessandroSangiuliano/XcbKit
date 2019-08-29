//
//  XCBSize.m
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBSize.h"

@implementation XCBSize

- (id) initWithWidht:(uint16_t)aWidth andHeight:(uint16_t)aHeight
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[%@] Error during initialization", NSStringFromClass([self class]));
		return nil;
	}
	
	width = aWidth;
	height = aHeight;
	
	return self;
}

- (void) setHeight:(uint16_t)aHeight
{
	height = aHeight;
}

- (uint16_t) getHeight
{
	return height;
}

- (void) setWidth:(uint16_t)aWidth
{
	width = aWidth;
}

- (uint16_t) getWidth
{
	return width;
}

@end
