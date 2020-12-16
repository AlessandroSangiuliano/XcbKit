//
// XCBCursor.h
// XCBKit
//
// Created by slex on 15/12/20.
//

#import <Foundation/Foundation.h>
#import "XCBScreen.h"
#import <xcb/xcb_cursor.h>

@class XCBConnection;

@interface XCBCursor : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBScreen *screen;
@property (nonatomic) xcb_cursor_context_t *context;
@property (strong, nonatomic) NSString *cursorPath;

- (instancetype)initWithConnection:(XCBConnection *)aConnection screen:(XCBScreen*)aScreen;
- (void) destroyContext;

@end