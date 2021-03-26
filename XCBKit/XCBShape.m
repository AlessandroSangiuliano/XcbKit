//
// XCBShape.m
// XCBKit
//
// Created by slex on 26/03/21.

#import "XCBShape.h"

@implementation XCBShape

@synthesize connection;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (!self)
    {
        NSLog(@"Unable to initialize...");
        return nil;
    }

    connection = aConnection;

    return self;
}

- (xcb_query_extension_reply_t*) checkSupported:(xcb_window_t) winId
{
    const xcb_query_extension_reply_t *shape_query;
    xcb_shape_query_extents_cookie_t extents_cookie;
    xcb_shape_query_extents_reply_t *reply;
    xcb_connection_t *conn = [connection connection];

    shape_query = xcb_get_extension_data(connection, &xcb_shape_id);

    if (!shape_query)
    {
        NSLog(@"Shape extension not supported");
        return NULL;
    }

    extents_cookie = xcb_shape_query_extents(conn, winId);
    reply = xcb_shape_query_extents_reply(conn, extents_cookie, NULL);

    return reply;
}


- (void) dealloc
{
    connection = nil;
}

@end