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
#import "CairoDrawer.h"
#import "XCBCreateWindowTypeRequest.h"
#import "XCBWindowTypeResponse.h"
#import "Transformers.h"

@implementation XCBTitleBar

@synthesize hideWindowButton;
@synthesize minimizeWindowButton;
@synthesize maximizeWindowButton;
@synthesize arc;
@synthesize connection;
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

    connection = aConnection;
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    [rootVisual setVisualTypeForScreen:screen];
    
    values[0] = [screen screen]->white_pixel;
    values[1] = TITLE_MASK_VALUES;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBTitleBarRequest];
    [request setDepth:XCB_COPY_FROM_PARENT];
    [request setParentWindow:aFrame];
    [request setXPosition:0];
    [request setYPosition:0];
    [request setWidth:[[[aFrame windowRect] size] getWidth]];
    [request setHeight:22];
    [request setBorderWidth:0.2];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setVisual:rootVisual];
    [request setValueMask:windowMask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* response = [connection createWindowForRequest:request registerWindow:NO];
    
    CsMapXCBWindowToXCBTitleBar([response titleBar], self);
    [connection registerWindow:self];
    
    response = nil;
    request = nil;
    
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE |  XCB_EVENT_MASK_BUTTON_PRESS ;
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    hideWindowButton = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
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
    [hideWindowButton setDraggable:NO];
    [hideWindowButton setIsCloseButton:YES];
    
    hideButtonColor = [NSColor colorWithCalibratedRed: 0.411 green: 0.176 blue: 0.673 alpha: 1]; //original: 0.7 0.427 1 1
    
    
    uint32_t gcMask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
    uint32_t gcValues[2];
    gcValues[0] = [screen screen]->black_pixel;
    gcValues[1] = 0;
    
    [hideWindowButton createGraphicContextWithMask:gcMask andValues:gcValues];
    
    minimizeWindowButton = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
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
    [minimizeWindowButton setDraggable:NO];
    [minimizeWindowButton setIsMinimizeButton:YES];
    
    minimizeButtonColor = [NSColor colorWithCalibratedRed: 0.9 green: 0.7 blue: 0.3 alpha: 1];
    
    maximizeWindowButton = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
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
    [maximizeWindowButton setDraggable:NO];
    [maximizeWindowButton setIsMaximizeButton:YES];
    
    maximizeButtonColor = [NSColor colorWithCalibratedRed:0 green:0.74 blue:1 alpha:1];
    
    [connection mapWindow:self];
    [connection mapWindow:hideWindowButton];
    [connection mapWindow:minimizeWindowButton];
    [connection mapWindow:maximizeWindowButton];
    ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    return self;
}

- (void) drawArcsForColor:(TitleBarColor)aColor
{
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:hideWindowButton visual:visual];
    
    NSColor *stopColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
    
    [drawer drawTitleBarButtonWithColor:aColor == TitleBarUpColor ? hideButtonColor : titleBarDownColor withStopColor:stopColor];
    
    drawer = nil;
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:minimizeWindowButton visual:visual];
    
    [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? minimizeButtonColor : titleBarDownColor  withStopColor:stopColor];
    
    drawer = nil;
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:maximizeWindowButton visual:visual];
    
    [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? maximizeButtonColor : titleBarDownColor  withStopColor:stopColor];
    
    drawer = nil;
}

- (void) drawTitleBarForColor:(TitleBarColor)aColor
{
    NSColor* aux;
    
    if (aColor == TitleBarUpColor)
        aux = titleBarUpColor;
    
    if (aColor == TitleBarDownColor)
        aux = titleBarDownColor;
    
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:self visual:visual];
    [drawer drawTitleBarWithColor:aux andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    
    /*** This is better than allocating/deallocating the drawer object for each window to draw, however find
     * a better solution to avoid all the sets methods/messages ***/
    
    [drawer setWindow:hideWindowButton];
    [drawer setHeight:[[[hideWindowButton windowRect] size] getHeight]];
    [drawer setWidth:[[[hideWindowButton windowRect] size] getWidth]];
    [drawer drawWindowWithColor:aux andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    
    [drawer setWindow:minimizeWindowButton];
    [drawer setHeight:[[[minimizeWindowButton windowRect] size] getHeight]];
    [drawer setWidth:[[[minimizeWindowButton windowRect] size] getWidth]];
    [drawer drawWindowWithColor:aux andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    
    [drawer setWindow:maximizeWindowButton];
    [drawer setHeight:[[[maximizeWindowButton windowRect] size] getHeight]];
    [drawer setWidth:[[[maximizeWindowButton windowRect] size] getWidth]];
    [drawer drawWindowWithColor:aux andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];

    
    drawer = nil;
    screen = nil;
    visual = nil;
    aux = nil;
}

- (void) drawTitleBarComponentsForColor:(TitleBarColor)aColor
{
    [self drawTitleBarForColor:aColor];
    [self drawArcsForColor:aColor];
}

- (void) setWindowTitle:(NSString *) title
{
    windowTitle = title;
    if ([title length] == 0)
    {
        NSLog(@"No title to set to the window.");
        return;
    }
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:self visual:visual];
    [drawer drawText:windowTitle withColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1]];
    drawer = nil;
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
    connection = nil;
    hideButtonColor = nil;
    minimizeButtonColor = nil;
    maximizeButtonColor = nil;
    titleBarUpColor = nil;
    titleBarDownColor = nil;
    ewmhService = nil;
}


@end
