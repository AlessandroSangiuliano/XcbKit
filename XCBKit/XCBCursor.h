//
// XCBCursor.h
// XCBKit
//
// Created by slex on 15/12/20.
//

#import <Foundation/Foundation.h>
#import "XCBScreen.h"
#import <xcb/xcb_cursor.h>
#import "enums/EMousePosition.h"

@class XCBConnection;

@interface XCBCursor : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBScreen *screen;
@property (nonatomic) xcb_cursor_context_t *context;
@property (strong, nonatomic) NSString *cursorPath;
@property (nonatomic) xcb_cursor_t cursor;
@property (strong, nonatomic) NSMutableDictionary *cursors;
@property (strong, nonatomic) NSString *leftPointerName;
@property (strong, nonatomic) NSString *resizeBottomCursorName;
@property (strong, nonatomic) NSString *resizeRightCursorName;
@property (strong, nonatomic) NSString *resizeLeftCursorName;
@property (strong, nonatomic) NSString *resizeTopCursorName;
@property (strong, nonatomic) NSString *resizeBottomRightCornerCursorName;
@property (assign, nonatomic) BOOL leftPointerSelected;
@property (assign, nonatomic) BOOL resizeBottomSelected;
@property (assign, nonatomic) BOOL resizeRightSelected;
@property (assign, nonatomic) BOOL resizeLeftSelected;
@property (assign, nonatomic) BOOL resizeBottomRightCornerSelected;
@property (assign, nonatomic) BOOL resizeTopSelected;

- (instancetype)initWithConnection:(XCBConnection *)aConnection screen:(XCBScreen*)aScreen;
- (BOOL) createContext;
- (void) destroyContext;
- (void) destroyCursor;

- (xcb_cursor_t) selectLeftPointerCursor;
- (xcb_cursor_t) selectResizeCursorForPosition:(MousePosition)position;

@end