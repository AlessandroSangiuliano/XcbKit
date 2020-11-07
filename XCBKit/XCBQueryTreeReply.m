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

- (void) dealloc
{
   /* if (queryReply)
        free(queryReply);*/

    rootWindow = nil;
    parentWindow = nil;
}

@end