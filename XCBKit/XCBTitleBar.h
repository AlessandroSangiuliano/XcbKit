//
//  XCBTitleBar.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 06/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBWindow.h"
#import "XCBFrame.h"
#import "XCBSize.h"

#ifndef TITLE_MASK

#define TITLE_MASK_VALUES XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION | \
XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | \
XCB_EVENT_MASK_KEY_PRESS

#endif


@interface XCBTitleBar : XCBWindow
{
    xcb_arc_t arcs[1];
}

@property (strong, nonatomic) NSColor *hideButtonColor;
@property (strong, nonatomic) NSColor *minimizeButtonColor;
@property (strong, nonatomic) NSColor *maximizeButtonColor;
@property(strong, nonatomic) XCBWindow *hideWindowButton;
@property(strong, nonatomic) XCBWindow *minimizeWindowButton;
@property(strong, nonatomic) XCBWindow *maximizeWindowButton;
@property(nonatomic) xcb_arc_t arc;
@property(strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) NSColor *titlebarColor;

- (id) initWithFrame:(XCBFrame*) aFrame withConnection:(XCBConnection*) aConnection;
- (void) drawArcs;
- (void) drawTitleBar;

/****************
 *    ACCESORS  *
 ***************/

- (xcb_arc_t*) arcs;
@end
