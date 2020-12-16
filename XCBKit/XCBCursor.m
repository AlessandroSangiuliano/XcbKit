//
// XCBCursor.m
// XCBKit
//
// Created by slex on 15/12/20.

#import "XCBCursor.h"
#import "XCBConnection.h"

@implementation XCBCursor

@synthesize connection;
@synthesize context;
@synthesize screen;
@synthesize cursorPath;

- (instancetype)initWithConnection:(XCBConnection *)aConnection screen:(XCBScreen*)aScreen
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    connection = aConnection;
    screen = aScreen;

    int success = xcb_cursor_context_new([connection connection], [screen screen], &context);

    if (success < 0)
    {
        NSLog(@"Error creating a new cursor context: %d", success);
        return self;
    }

    xcb_cursor_t cursor = xcb_cursor_load_cursor(context, "top_left_arrow");
    XCBWindow *rootWindow = [screen rootWindow];
    [rootWindow changeAttributes:&cursor withMask:XCB_CW_CURSOR checked:NO];
    rootWindow = nil;

    return self;
}


- (void) destroyContext
{
    xcb_cursor_context_free(context);
}

- (void) dealloc
{
    connection = nil;
    screen = nil;
    cursorPath = nil;

    if (context != NULL)
        [self destroyContext];
}

@end