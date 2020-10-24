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
#import "services/EWMHService.h"
#import "enums/ETitleBarColor.h"
#import "utils/XCBShape.h"


#ifndef TITLE_MASK

#define TITLE_MASK_VALUES XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION | \
XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | \
XCB_EVENT_MASK_KEY_PRESS

#endif


@interface XCBTitleBar : XCBWindow
{
    xcb_arc_t arcs[1];
    NSString *windowTitle;
}

@property (nonatomic) XCBColor hideButtonColor;
@property (nonatomic) XCBColor minimizeButtonColor;
@property (nonatomic) XCBColor maximizeButtonColor;
@property (strong, nonatomic) XCBWindow *hideWindowButton;
@property (strong, nonatomic) XCBWindow *minimizeWindowButton;
@property (strong, nonatomic) XCBWindow *maximizeWindowButton;
@property (nonatomic) xcb_arc_t arc;
@property (nonatomic) XCBColor titleBarUpColor;
@property (nonatomic) XCBColor titleBarDownColor;
@property (strong, nonatomic) EWMHService *ewmhService;

- (id) initWithFrame:(XCBFrame*) aFrame withConnection:(XCBConnection*) aConnection;
- (void) drawArcsForColor:(TitleBarColor)aColor;

/***
* Draws the titlebar with the color argument.
* aColor: The color to draw the title bar; if nil titleBarStandardColor is used.
***/

- (void) drawTitleBarForColor:(TitleBarColor)aColor; //maybe is better to set the color all the time if the default one is not desidered.
- (void) setWindowTitle:(NSString*) title;
- (void) drawTitleBarComponentsForColor:(TitleBarColor)aColor;
- (void) generateButtons;

/****************
 *    ACCESORS  *
 ***************/

- (xcb_arc_t*) arcs;
@end
