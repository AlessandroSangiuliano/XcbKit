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
@synthesize cursor;
@synthesize leftPointerName;
@synthesize resizeBottomCursorName;
@synthesize resizeRightCursorName;
@synthesize cursors;
@synthesize leftPointerSelected;
@synthesize resizeBottomSelected;
@synthesize resizeRightSelected;
@synthesize resizeLeftCursorName;
@synthesize resizeLeftSelected;
@synthesize resizeBottomRightCornerCursorName;
@synthesize resizeBottomRightCornerSelected;
@synthesize resizeTopCursorName;
@synthesize resizeTopSelected;

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

    BOOL success = [self createContext];

    if (!success)
    {
        NSLog(@"Error creating a new cursor context: %d", success);
        return self;
    }

    cursors = [[NSMutableDictionary alloc] init];

    leftPointerName = @"left_ptr";
    resizeBottomCursorName = @"s-resize";
    resizeRightCursorName = @"w-resize";
    resizeLeftCursorName = @"e-resize";
    resizeBottomRightCornerCursorName = @"nwse-resize";
    resizeTopCursorName = @"n-resize";


    cursor = xcb_cursor_load_cursor(context, [leftPointerName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:leftPointerName];
    cursor = xcb_cursor_load_cursor(context, [resizeBottomCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeBottomCursorName];
    cursor = xcb_cursor_load_cursor(context, [resizeRightCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeRightCursorName];
    cursor = xcb_cursor_load_cursor(context, [resizeLeftCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeLeftCursorName];
    cursor = xcb_cursor_load_cursor(context, [resizeLeftCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeLeftCursorName];
    cursor = xcb_cursor_load_cursor(context, [resizeBottomRightCornerCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeBottomRightCornerCursorName];
    cursor = xcb_cursor_load_cursor(context, [resizeTopCursorName cString]);
    [cursors setObject:[NSNumber numberWithUnsignedInt:cursor] forKey:resizeTopCursorName];

    return self;
}

- (xcb_cursor_t) selectLeftPointerCursor
{
    cursor = [[cursors objectForKey:leftPointerName] unsignedIntValue];
    leftPointerSelected = YES;
    resizeBottomSelected = NO;
    resizeRightSelected = NO;
    resizeLeftSelected = NO;
    resizeTopSelected = NO;
    resizeBottomRightCornerSelected = NO;
    return cursor;
}

- (xcb_cursor_t) selectResizeCursorForPosition:(MousePosition)position
{
    switch (position)
    {
        case BottomBorder:
            cursor = [[cursors objectForKey:resizeBottomCursorName] unsignedIntValue];
            leftPointerSelected = NO;
            resizeBottomSelected = YES;
            resizeRightSelected = NO;
            resizeLeftSelected = NO;
            resizeBottomRightCornerSelected = NO;
            resizeTopSelected = NO;
            break;
        case RightBorder:
            cursor = [[cursors objectForKey:resizeRightCursorName] unsignedIntValue];
            leftPointerSelected = NO;
            resizeBottomSelected = NO;
            resizeRightSelected = YES;
            resizeLeftSelected = NO;
            resizeBottomRightCornerSelected = NO;
            resizeTopSelected = NO;
            break;
        case LeftBorder:
            cursor = [[cursors objectForKey:resizeLeftCursorName] unsignedIntValue];
            leftPointerSelected = NO;
            resizeBottomSelected = NO;
            resizeRightSelected = NO;
            resizeLeftSelected = YES;
            resizeBottomRightCornerSelected = NO;
            resizeTopSelected = NO;
            break;
        case BottomRightCorner:
            cursor = [[cursors objectForKey:resizeBottomRightCornerCursorName] unsignedIntValue];
            leftPointerSelected = NO;
            resizeBottomSelected = NO;
            resizeRightSelected = NO;
            resizeLeftSelected = NO;
            resizeBottomRightCornerSelected = YES;
            resizeTopSelected = NO;
            break;
        case TopBorder:
            cursor = [[cursors objectForKey:resizeTopCursorName] unsignedIntValue];
            leftPointerSelected = NO;
            resizeBottomSelected = NO;
            resizeRightSelected = NO;
            resizeLeftSelected = NO;
            resizeBottomRightCornerSelected = NO;
            resizeTopSelected = YES;
           break;

        default:
            break;
    }

    return cursor;
}

- (BOOL) createContext
{
    int success = xcb_cursor_context_new([connection connection], [screen screen], &context);

    if (success < 0)
        return NO;

    return YES;
}

- (void) destroyContext
{
    xcb_cursor_context_free(context);
}

- (void) destroyCursor
{
    xcb_free_cursor([connection connection], cursor);
}

- (void) dealloc
{
    connection = nil;
    screen = nil;
    cursorPath = nil;
    cursors = nil;

    resizeTopCursorName = nil;
    resizeBottomRightCornerCursorName = nil;
    resizeLeftCursorName = nil;
    resizeRightCursorName = nil;
    resizeBottomCursorName = nil;
    leftPointerName = nil;

    if (context != NULL)
        [self destroyContext];


}

@end