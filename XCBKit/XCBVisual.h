//
//  XCBVisual.h
//  XCBKit
//
//  Created by alex on 29/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <xcb/xcb.h>
#import "XCBScreen.h"

@interface XCBVisual : NSObject
{
	xcb_visualid_t visualId;
	xcb_visualtype_t *visualType;
}

- (xcb_visualtype_t*) visualType;
- (void) setVisualType:(xcb_visualtype_t*) aVisualType;

- (xcb_visualid_t) visualId;
- (void) setVisualId: (xcb_visualid_t) aVisualId;
- (id) initWithVisualId:(xcb_visualid_t)aVisualId;
- (id) initWithVisualId:(xcb_visualid_t) aVisualId withVisualType:(xcb_visualtype_t*) aVisualType;
- (void) setVisualTypeForScreen:(XCBScreen*) aScreen;

@end
