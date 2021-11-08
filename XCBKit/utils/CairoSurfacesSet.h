//
//  CairoIconSet.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/10/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <cairo/cairo-xcb.h>
#import <cairo/cairo.h>

@class XCBConnection;

@interface CairoSurfacesSet : NSObject

@property (strong, nonatomic) NSMutableArray *cairoSurfaces;
@property (strong, nonatomic) XCBConnection *connection;

- (id) initWithConnection:(XCBConnection*)aConnection;
- (NSUInteger) size;
- (void) pushSurface:(cairo_surface_t*) surface;
- (void) removeSurface:(cairo_surface_t*) surface;
- (void) cleanSet;
- (void) buildSetFromReply:(xcb_get_property_reply_t *)aReply;

@end