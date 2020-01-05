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

- (id) initWithVisualId:(xcb_visualid_t)aVisualId withVisualType:(xcb_visualtype_t*)aVisualType
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

- (void) setVisualTypeForScreen:(XCBScreen*) aScreen
{
    xcb_depth_iterator_t depth_iter = xcb_screen_allowed_depths_iterator([aScreen screen]);
    
    for (; depth_iter.rem; xcb_depth_next(&depth_iter))
    {
        xcb_visualtype_iterator_t visual_iter = xcb_depth_visuals_iterator(depth_iter.data);
        
        for (; visual_iter.rem; xcb_visualtype_next(&visual_iter))
            
            if (visualId == visual_iter.data->visual_id)
                
                [self setVisualType:visual_iter.data];
        
    }
}

- (void) setVisualId:(xcb_visualid_t)aVisualId
{
	visualId = aVisualId;
}

- (void) setVisualType:(xcb_visualtype_t*)aVisualType
{
	visualType = aVisualType;
}

- (xcb_visualid_t) visualId
{
	return visualId;
}

- (xcb_visualtype_t*) visualType
{
	return visualType;
}

- (void) dealloc
{
    //free(visualType);
}


@end
