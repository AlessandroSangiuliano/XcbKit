//
// XCBQueryTreeReply.h
// XCBKit
//
// Created by slex on 21/10/20.
//

#import <Foundation/Foundation.h>
#import "XCBReply.h"

@class XCBWindow;
@class XCBConnection;

@interface XCBQueryTreeReply : XCBReply
{
}

@property (strong, nonatomic) XCBWindow *rootWindow;
@property (strong, nonatomic) XCBWindow *parentWindow;
@property (nonatomic) xcb_query_tree_reply_t *queryReply;
@property (nonatomic, assign) int len;

- (id) initWithReply:(xcb_query_tree_reply_t *)aReply andConnection:(XCBConnection*)aConnection;
- (xcb_window_t *)queryTreeAsArray;

@end