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
@synthesize windowRect;


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
    
    XCBWindow *titleAusWindow = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
                  withParentWindow:aFrame
                     withXPosition:0
                     withYPosition:0
                         withWidth:[[[aFrame windowRect] size] getWidth]
                        withHeight: 22
                  withBorrderWidth:0.2
                      withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                      withVisualId:rootVisual
                     withValueMask:windowMask
                     withValueList:values];
    
    aboveWindow = [titleAusWindow aboveWindow];
    parentWindow = aFrame;
    isMapped = [titleAusWindow isMapped];
    attributes = [titleAusWindow attributes];
    window = [titleAusWindow window];
    windowRect = [titleAusWindow windowRect];
    
    titleAusWindow = nil;
    
    titlebarColor = [NSColor colorWithCalibratedRed:0.720 green:0.720 blue:0.720 alpha:1];
    
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE;
    
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
    
    maximizeButtonColor = [NSColor colorWithCalibratedRed:0 green:0.74 blue:1 alpha:1];
    
    [connection mapWindow:self];
    [connection mapWindow:hideWindowButton];
    [connection mapWindow:minimizeWindowButton];
    [connection mapWindow:maximizeWindowButton];
    
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
}


@end
