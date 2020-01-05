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

typedef NS_ENUM(NSInteger, childrenMask)
{
    TitleBar = 0,
    ClientWindow = 1
};

@interface XCBFrame : XCBWindow
{
    NSMutableDictionary *children;
}

- (id) initWithClientWindow:(XCBWindow*) aClientWindow withConnection:(XCBConnection*) aConnection withXcbWindow:(xcb_window_t) xcbWindow;

- (void) addChildWindow:(XCBWindow*) aChild withKey:(childrenMask) keyMask;
- (void) removeChild:(childrenMask) frameChild;


 /********************************
 *                               *
 *            ACCESSORS          *
 *                               *
 ********************************/

- (void) setChildren:(NSMutableDictionary*) aChildrenSet;
- (NSMutableDictionary*) getChildren;

@end
