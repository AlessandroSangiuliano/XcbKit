//
//  XCBGeometry.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 24/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "utils/XCBShape.h"

@class XCBWindow;

@interface XCBGeometry : NSObject

@property (nonatomic) uint16_t borderWidth;
@property (nonatomic) uint8_t depth;
@property (nonatomic) XCBRect rect;
@property (strong, nonatomic) XCBWindow *rootWindow;

- (id) init;
- (id) initWithGeometryReply:(xcb_get_geometry_reply_t*)aReplay;
- (void) description;

@end
