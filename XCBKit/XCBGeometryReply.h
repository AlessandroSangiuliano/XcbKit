//
//  XCBGeometry.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 24/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils/XCBShape.h"
#import "XCBReply.h"

@class XCBWindow;

@interface XCBGeometryReply : XCBReply

@property (nonatomic) uint16_t borderWidth;
@property (nonatomic) uint8_t depth;
@property (nonatomic) XCBRect rect;
@property (strong, nonatomic) XCBWindow *rootWindow;
@property (nonatomic) xcb_get_geometry_reply_t *geometryReply;

- (id) initWithReply:(xcb_get_geometry_reply_t*)aReplay;
- (void) description;

@end
