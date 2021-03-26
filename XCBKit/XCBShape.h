//
// XCBShape.h
// XCBKit
//
// Created by slex on 26/03/21.
//

#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#include <xcb/shape.h>

@interface XCBShape : NSObject
{
}

@property (strong, nonatomic) XCBConnection* connection;

- (id) initWithConnection:(XCBConnection*)aConnection;
- (xcb_query_extension_reply_t*) checkSupported:(xcb_window_t) winId;

@end