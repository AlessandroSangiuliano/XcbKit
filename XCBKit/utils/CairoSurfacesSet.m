//
//  CairoIconSet.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/10/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "CairoSurfacesSet.h"
#import "CairoDrawer.h"

@implementation CairoSurfacesSet

@synthesize cairoSurfaces;
@synthesize connection;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    cairoSurfaces = [[NSMutableArray alloc] init];
    connection = aConnection;

    return self;
}

- (NSUInteger) size
{
    return [cairoSurfaces count];
}

- (void) pushSurface:(cairo_surface_t*)surface
{
    NSValue *value = [NSValue valueWithPointer:surface];
    [cairoSurfaces addObject:value];
    value = nil;
}

-(void) removeSurface:(cairo_surface_t*)surface
{
    NSValue *value = [NSValue valueWithPointer:surface];
    [cairoSurfaces removeObject:value];
    value = nil;
}

-(void) cleanSet
{
    [cairoSurfaces removeAllObjects];
}

- (void) buildSetFromReply:(xcb_get_property_reply_t*)aReply
{
    uint32_t *data, *data_end;
    cairo_surface_t *surface;

    [self cleanSet];

    if (!aReply || aReply->type != XCB_ATOM_CARDINAL || aReply->format != 32)
        return;

    data = (uint32_t*) xcb_get_property_value(aReply);
    data_end = &data[aReply->length];

    if (!data)
        return;
    
    while ((surface = [self nextSurface:&data end:data_end]) != NULL)
        [self pushSurface:surface];

}

- (cairo_surface_t*) nextSurface:(uint32_t **)data end:(uint32_t *)data_end
{
    uint32_t width, height;
    uint64_t data_len;
    uint32_t *icon_data;

    if(data_end - *data <= 2)
        return NULL;

    width = (*data)[0];
    height = (*data)[1];

    data_len = width * (uint64_t) height;
    if (width < 1 || height < 1 || data_len > (uint64_t) (data_end - *data) - 2)
        return NULL;

    icon_data = *data + 2;
    *data += 2 + data_len;

    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection];
    cairo_surface_t *surface = [drawer drawContentFromData:icon_data withWidht:width andHeight:height];
    drawer = nil;

    return surface;
}

- (void) dealloc
{
    cairoSurfaces = nil;
    connection = nil;
}

@end