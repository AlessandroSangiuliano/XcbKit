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
@synthesize titlebarColor;
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

- (void) drawArcs
{
    /*int height = [[[hideWindowButton windowRect] size] getHeight] - 1;
    int width = [[[hideWindowButton windowRect] size] getWidth] - 1;
    arc.angle1 = 0;
    arc.angle2 = 360 << 6;
    arc.height = height;
    arc.width = width;
    arc.x = 0;
    arc.y = 0;
    
    arcs[0] = arc;
    int size = sizeof(arcs)/sizeof(arcs[0]);*/
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:hideWindowButton visual:visual];
    
    NSColor *stopColor = [NSColor colorWithCalibratedRed:1 green:1 blue:1 alpha:1];
    
    [drawer drawTitleBarButtonWithColor:hideButtonColor withStopColor:stopColor];
    
    drawer = nil;
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:minimizeWindowButton visual:visual];
    
    [drawer drawTitleBarButtonWithColor:minimizeButtonColor withStopColor:stopColor];
    
    drawer = nil;
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:maximizeWindowButton visual:visual];
    
    [drawer drawTitleBarButtonWithColor:maximizeButtonColor withStopColor:stopColor];
    
    drawer = nil;
    
    //xcb_poly_arc([connection connection], [hideWindowButton window], [hideWindowButton graphicContextId], size, arcs);
    //xcb_poly_arc([connection connection], [minizeWindowButton window], [minizeWindowButton graphicContextId], size, arcs);
    //xcb_poly_arc([connection connection], [maximizeWindowButton window], [hideWindowButton graphicContextId], size, arcs);
    
}

- (void) drawTitleBar
{
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:self visual:visual];
    [drawer drawTitleBarWithColor:titlebarColor andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    drawer = nil;
    
    /*** My GOD what a bad thing, just set the window OMG ***/
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:hideWindowButton visual:visual];
    [drawer drawWindowWithColor:titlebarColor andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    drawer = nil;
    
    drawer = [[CairoDrawer alloc] initWithConnection:connection window:minimizeWindowButton visual:visual];
    [drawer drawWindowWithColor:titlebarColor andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    drawer = nil;

    drawer = [[CairoDrawer alloc] initWithConnection:connection window:maximizeWindowButton visual:visual];
    [drawer drawWindowWithColor:titlebarColor andStopColor:[NSColor colorWithCalibratedRed:0.850 green:0.850 blue:0.850 alpha:1]];
    
    drawer = nil;

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
    titlebarColor = nil;
    ewmhService = nil;
}


@end
