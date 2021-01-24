//
// XCBQueryTreeReply.m
// XCBKit
//
// Created by slex on 21/10/20.

#import "XCBQueryTreeReply.h"
#import "XCBWindow.h"
#import "XCBConnection.h"

@implementation XCBQueryTreeReply

@synthesize rootWindow;
@synthesize parentWindow;
@synthesize queryReply;

- (id) initWithReply:(xcb_query_tree_reply_t *)aReply andConnection:(XCBConnection*)aConnection
{
    self = [super initWithReply:aReply];

    if (self == nil)
        return nil;

    queryReply = aReply;
    rootWindow = [[XCBWindow alloc] initWithXCBWindow:aReply->root andConnection:aConnection];
    parentWindow = [[XCBWindow alloc] initWithXCBWindow:aReply->parent andConnection:aConnection];

    return self;
}

- (NSMutableArray*) children
{
    int len = xcb_query_tree_children_length(queryReply);
    xcb_window_t *chldrn = xcb_query_tree_children(queryReply);
    XCBConnection *connection = [rootWindow connection];

    NSMutableArray *children = [[NSMutableArray alloc] initWithCapacity:len];

    for (int i = 0; i < len; ++i)
    {
        XCBWindow *window = [connection windowForXCBId:chldrn[i]];
        [children addObject:window];
        NSLog(@"Window class %@, %@", [[window windowClass] objectAtIndex:0], [[window windowClass] objectAtIndex:1]);
        window = nil;
    }

    connection = nil;
    return children;
}

- (void) dealloc
{
   /* if (queryReply)
        free(queryReply);*/

    rootWindow = nil;
    parentWindow = nil;
}

@end