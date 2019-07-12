//
//  XCBVisual.m
//  XCBKit
//
//  Created by alex on 29/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBVisual.h"


@implementation XCBVisual

- (id) initWithVisualId:(xcb_visualid_t)aVisualId
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[XCBVisual] super init failed");
		return nil;
	}
	
	visualId = aVisualId;
	return self;
}

- (id) initWithVisualId:(xcb_visualid_t)aVisualId withVisualType:(xcb_visualtype_t)aVisualType
{
	self = [super init];
	
	if (self == nil)
	{
		NSLog(@"[XCBVisual] super init failed");
		return nil;
	}
	
	visualId = aVisualId;
	visualType = aVisualType;
	
	return self;
}

- (void) setVisualId:(xcb_visualid_t)aVisualId
{
	visualId = aVisualId;
}

- (void) setVisualType:(xcb_visualtype_t)aVisualType
{
	visualType = aVisualType;
}

- (xcb_visualid_t) visualId
{
	return visualId;
}

- (xcb_visualtype_t) visualType
{
	return visualType;
}


@end
