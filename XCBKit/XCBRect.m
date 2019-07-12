//
//  XCBRect.m
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBRect.h"
#import "XCBPoint.h"

@implementation XCBRect

- (id) initWithPoint:(XCBPoint *)aPoint andSize:(XCBSize *)aSize
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[%@] Error during initialization", NSStringFromClass([self class]));
		return nil;
	}
	
	point = aPoint;
	size = aSize;
	return self;
}

- (void) setPoint:(XCBPoint *)aPoint
{
	point = aPoint;
}

- (XCBPoint*) point
{
	return point;
}

- (void) setSize:(XCBSize *)aSize
{
	size = aSize;
}

- (XCBSize*) size
{
	return size;
}

- (NSString *) description
{
	return [NSString stringWithFormat:@"X and Y coordinates: (%hd, %hd), width and height (%hd, %hd)",
			[point getX],
			[point getY],
			[size getWidth],
			[size getHeight]];
}

+ (XCBRect *) rectFromXcbRectangle:(xcb_rectangle_t)rect
{
	XCBPoint *point = [[XCBPoint alloc] initWithX:rect.x andY:rect.y];
	XCBSize *size = [[XCBSize alloc] initWithWidht:rect.width andHeight:rect.height];

	return [[XCBRect alloc] initWithPoint:point andSize:size];
}

@end
