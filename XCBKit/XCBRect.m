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

@synthesize offset;

- (id) initWithPosition:(XCBPoint *)aPoint andSize:(XCBSize *)aSize
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[%@] Error during initialization", NSStringFromClass([self class]));
		return nil;
	}
	
	position = aPoint;
	size = aSize;
    offset = [[XCBPoint alloc] initWithX:0 andY:0];
    
	return self;
}

- (id) initWithExposeEvent:(xcb_expose_event_t *)anEvent
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"[%@] Error during initialization", NSStringFromClass([self class]));
		return nil;
    }
    
    position = [[XCBPoint alloc] initWithX:anEvent->x andY:anEvent->y];
    size = [[XCBSize alloc] initWithWidht:anEvent->width andHeight:anEvent->height];
    offset = [[XCBPoint alloc] initWithX:0 andY:0];
    
    return self;
}

- (void) setPosition:(XCBPoint *)aPoint
{
	position = aPoint;
}

- (XCBPoint*) position
{
	return position;
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
			[position getX],
			[position getY],
			[size getWidth],
			[size getHeight]];
}

+ (XCBRect *) rectFromXcbRectangle:(xcb_rectangle_t)rect
{
	XCBPoint *point = [[XCBPoint alloc] initWithX:rect.x andY:rect.y];
	XCBSize *size = [[XCBSize alloc] initWithWidht:rect.width andHeight:rect.height];

	return [[XCBRect alloc] initWithPosition:point andSize:size];
}

- (xcb_rectangle_t) xcbRectangle
{
    xcb_rectangle_t rect;
    rect.height = [size getHeight];
    rect.width = [size getWidth];
    rect.x = [position getX];
    rect.y= [position getY];
    
    return rect;
}

- (void) dealloc
{
    position = nil;
    size = nil;
}
@end
