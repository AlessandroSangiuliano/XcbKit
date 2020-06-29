//
//  XCBTitleBar.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 06/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBTitleBar.h"
#import "XCBConnection.h"
#import "XCBFrame.h"
#import <cairo/cairo.h>
#import <cairo/cairo-xcb.h>
#import "utils/CairoDrawer.h"
#import "utils/XCBCreateWindowTypeRequest.h"
#import "utils/XCBWindowTypeResponse.h"
#import "functions/Transformers.h"

@implementation XCBTitleBar

@synthesize hideWindowButton;
@synthesize minimizeWindowButton;
@synthesize maximizeWindowButton;
@synthesize arc;
@synthesize hideButtonColor;
@synthesize minimizeButtonColor;
@synthesize maximizeButtonColor;
@synthesize titleBarUpColor;
@synthesize titleBarDownColor;
@synthesize ewmhService;


- (id) initWithFrame:(XCBFrame *)aFrame withConnection:(XCBConnection *)aConnection
{
    self = [super init];
    uint32_t values[2];
    
    windowMask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    [super setConnection:aConnection];
    
    XCBScreen *screen = [[[super connection] screens] objectAtIndex:0];
    XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    [rootVisual setVisualTypeForScreen:screen];
    
    values[0] = [screen screen]->white_pixel;
    values[1] = TITLE_MASK_VALUES;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBTitleBarRequest];
    [request setDepth:XCB_COPY_FROM_PARENT];
    [request setParentWindow:aFrame];
    [request setXPosition:0];
    [request setYPosition:0];
    [request setWidth:[aFrame windowRect].size.width];
    [request setHeight:22];
    [request setBorderWidth:0.2];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setVisual:rootVisual];
    [request setValueMask:windowMask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* response = [[super connection] createWindowForRequest:request registerWindow:NO];
    
    CsMapXCBWindowToXCBTitleBar([response titleBar], self);
    [[super connection] registerWindow:self];
    
    response = nil;
    request = nil;
    
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE |  XCB_EVENT_MASK_BUTTON_PRESS ;
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t gcMask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES; //necessary code?
    uint32_t gcValues[2];
    gcValues[0] = [screen screen]->black_pixel;
    gcValues[1] = 0;
    
    if ([[aFrame childWindowForKey:ClientWindow] canClose])
    {
        hideWindowButton = [[super connection] createWindowWithDepth:XCB_COPY_FROM_PARENT
                                                    withParentWindow:self
                                                       withXPosition:5
                                                       withYPosition:5
                                                           withWidth:14
                                                          withHeight:14
                                                    withBorrderWidth:0
                                                        withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                        withVisualId:rootVisual
                                                       withValueMask:mask
                                                       withValueList:values];
        
        [hideWindowButton setWindowMask:mask];
        [hideWindowButton setCanMove:NO];
        [hideWindowButton setIsCloseButton:YES];

        hideButtonColor = XCBMakeColor(0.411, 0.176, 0.673, 1); //original: 0.7 0.427 1 1
        
        [hideWindowButton createGraphicContextWithMask:gcMask andValues:gcValues];
    }
    
    if ([[aFrame childWindowForKey:ClientWindow] canMinimize])
    {
        minimizeWindowButton = [[super connection] createWindowWithDepth:XCB_COPY_FROM_PARENT
                                                        withParentWindow:self
                                                           withXPosition:24
                                                           withYPosition:5
                                                               withWidth:14
                                                              withHeight:14
                                                        withBorrderWidth:0
                                                            withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                            withVisualId:rootVisual
                                                           withValueMask:mask
                                                           withValueList:values];
        
        [minimizeWindowButton createGraphicContextWithMask:gcMask andValues:gcValues];
        [minimizeWindowButton setWindowMask:mask];
        [minimizeWindowButton setCanMove:NO];
        [minimizeWindowButton setIsMinimizeButton:YES];
        
        minimizeButtonColor = XCBMakeColor(0.9,0.7,0.3,1);
    }
    
    if ([[aFrame childWindowForKey:ClientWindow] canFullscreen])
    {
        maximizeWindowButton = [[super connection] createWindowWithDepth:XCB_COPY_FROM_PARENT
                                                        withParentWindow:self
                                                           withXPosition:44
                                                           withYPosition:5
                                                               withWidth:14
                                                              withHeight:14
                                                        withBorrderWidth:0
                                                            withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                            withVisualId:rootVisual
                                                           withValueMask:mask
                                                           withValueList:values];
        
        [maximizeWindowButton createGraphicContextWithMask:gcMask andValues:gcValues];
        [maximizeWindowButton setWindowMask:mask];
        [maximizeWindowButton setCanMove:NO];
        [maximizeWindowButton setIsMaximizeButton:YES];
        
        maximizeButtonColor = XCBMakeColor(0,0.74,1,1);
    }
    
    [[super connection] mapWindow:self];
    [[super connection] mapWindow:hideWindowButton];
    [[super connection] mapWindow:minimizeWindowButton];
    [[super connection] mapWindow:maximizeWindowButton];
    ewmhService = [EWMHService sharedInstanceWithConnection:[super connection]];
    
    return self;
}

- (void) drawArcsForColor:(TitleBarColor)aColor
{
    XCBColor stopColor = XCBMakeColor(1,1,1,1);
    XCBScreen *screen = [[[super connection] screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = nil;
    
    if (hideWindowButton != nil)
    {
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:hideWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor:aColor == TitleBarUpColor ? hideButtonColor : titleBarDownColor withStopColor:stopColor];
        
        drawer = nil;
    }
    
    if (minimizeWindowButton != nil)
    {
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:minimizeWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? minimizeButtonColor : titleBarDownColor  withStopColor:stopColor];
        
        drawer = nil;
    }
    
    if (maximizeWindowButton != nil)
    {
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:maximizeWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? maximizeButtonColor : titleBarDownColor  withStopColor:stopColor];
        
        drawer = nil;
    }
    
    screen = nil;
    visual = nil;
}

- (void) drawTitleBarForColor:(TitleBarColor)aColor
{
    XCBColor aux;
    
    if (aColor == TitleBarUpColor)
        aux = titleBarUpColor;
    
    if (aColor == TitleBarDownColor)
        aux = titleBarDownColor;
    
    
    XCBScreen *screen = [[[super connection] screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:self visual:visual];
    
    XCBColor stopColor = XCBMakeColor(0.850, 0.850, 0.850, 1);
    [drawer drawTitleBarWithColor:aux andStopColor: stopColor];
    
    /*** This is better than allocating/deallocating the drawer object for each window to draw, however find
     * a better solution to avoid all the sets methods/messages ***/
    
    if (hideWindowButton != nil)
    {
        [drawer setWindow:hideWindowButton];
        [drawer setHeight:[hideWindowButton windowRect].size.height];
        [drawer setWidth:[hideWindowButton windowRect].size.width];
        [drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    if (minimizeWindowButton != nil)
    {
        [drawer setWindow:minimizeWindowButton];
        [drawer setHeight:[minimizeWindowButton windowRect].size.height];
        [drawer setWidth:[minimizeWindowButton windowRect].size.width];
        [drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    if (maximizeWindowButton != nil)
    {
        [drawer setWindow:maximizeWindowButton];
        [drawer setHeight:[maximizeWindowButton windowRect].size.height];
        [drawer setWidth:[maximizeWindowButton windowRect].size.width];
        [drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    drawer = nil;
    screen = nil;
    visual = nil;
}

- (void) drawTitleBarComponentsForColor:(TitleBarColor)aColor
{
    [self drawTitleBarForColor:aColor];
    [self drawArcsForColor:aColor];
    [self setWindowTitle:windowTitle];
}

- (void) setWindowTitle:(NSString *) title
{
    windowTitle = title;
    if ([title length] == 0)
    {
        NSLog(@"No title to set to the window.");
        return;
    }
    
    XCBScreen *screen = [[[super connection] screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:self visual:visual];
    XCBColor black = XCBMakeColor(0,0,0,1);
    [drawer drawText:windowTitle withColor:black];
    
    drawer = nil;
    screen = nil;
    visual = nil;
}

- (xcb_arc_t*) arcs
{
    return arcs;
}

- (void) dealloc
{
    hideWindowButton = nil;
    minimizeWindowButton = nil;
    maximizeWindowButton = nil;
    ewmhService = nil;
}


@end
