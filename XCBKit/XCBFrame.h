//
//  XCBFrame.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 05/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBWindow.h"
#import "XCBConnection.h"

#define WM_MIN_WINDOW_HEIGHT 431
#define WM_MIN_WINDOW_WIDTH 496

typedef NS_ENUM(NSInteger, childrenMask)
{
    TitleBar = 0,
    ClientWindow = 1
};

@interface XCBFrame : XCBWindow
{
    NSMutableDictionary *children;
}

@property (nonatomic) int minHeightHint;
@property (nonatomic) int minWidthHint;
@property (strong, nonatomic) XCBConnection *connection;
@property (nonatomic) BOOL rightBorderClicked;
@property (nonatomic) BOOL bottomBorderClicked;
@property (nonatomic) BOOL leftBorderClicked;
@property (nonatomic) BOOL topBorderClicked;
@property (nonatomic) XCBPoint offset;

- (id) initWithClientWindow:(XCBWindow*) aClientWindow withConnection:(XCBConnection*) aConnection;
- (id) initWithClientWindow:(XCBWindow*) aClientWindow withConnection:(XCBConnection*) aConnection withXcbWindow:(xcb_window_t) xcbWindow;

- (void) addChildWindow:(XCBWindow*) aChild withKey:(childrenMask) keyMask;
- (XCBWindow*) childWindowForKey:(childrenMask) key;
- (void) removeChild:(childrenMask) frameChild;
- (void) resize:(xcb_motion_notify_event_t *)anEvent;
- (void) moveTo:(NSPoint)coordinates;


 /********************************
 *                               *
 *            ACCESSORS          *
 *                               *
 ********************************/

- (void) setChildren:(NSMutableDictionary*) aChildrenSet;
- (NSMutableDictionary*) getChildren;
- (void) decorateClientWindow;

@end
