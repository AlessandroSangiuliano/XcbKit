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

@implementation XCBTitleBar

@synthesize hideWindowButton;
@synthesize minizeWindowButton;
@synthesize maximizeWindowButton;


- (id) initWithFrame:(XCBFrame *)aFrame withConnection:(XCBConnection *)aConnection
{
    self = [super init];
    XCBScreen *screen = [[XCBConn screens] objectAtIndex:0];
    XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen].root_visual];
    
    XCBWindow *titleAusWindow = [aConnection createWindowWithDepth:XCB_COPY_FROM_PARENT
                  withParentWindow:aFrame
                     withXPosition:0
                     withYPosition:1
                         withWidth:[[[aFrame windowRect] size] getWidth]
                        withHeight: 22
                  withBorrderWidth:1
                      withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                      withVisualId:rootVisual
                     withValueMask:0
                     withValueList:NULL];
    
    aboveWindow = [titleAusWindow aboveWindow];
    parentWindow = aFrame;
    isMapped = [titleAusWindow isMapped];
    attributes = [titleAusWindow attributes];
    window = [titleAusWindow window];
    
    titleAusWindow = nil;
    
    hideWindowButton = [aConnection createWindowWithDepth:XCB_COPY_FROM_PARENT
                  withParentWindow:self
                     withXPosition:5
                     withYPosition:5
                         withWidth:10
                        withHeight:10
                  withBorrderWidth:1
                      withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                      withVisualId:rootVisual
                     withValueMask:0
                     withValueList:NULL];
    
    [hideWindowButton createGraphicContext];
    
    xcb_arc_t arc;
    arc.angle1 = 0;
    arc.angle2 = 100 << 6;
    arc.height = [[[hideWindowButton windowRect] size] getHeight];
    arc.width = [[[hideWindowButton windowRect] size] getWidth];
    arc.x = [[[hideWindowButton windowRect] point] getX];
    arc.y = [[[hideWindowButton windowRect] point] getY];
    
    xcb_arc_t arcs[1];
    arcs[0] = arc;
    
    xcb_poly_arc([aConnection connection], window, [hideWindowButton graphicContextId], 1, arcs);
    
    minizeWindowButton = [aConnection createWindowWithDepth:XCB_COPY_FROM_PARENT
                                           withParentWindow:self
                                              withXPosition:21
                                              withYPosition:5
                                                  withWidth:10
                                                 withHeight:10
                                           withBorrderWidth:1
                                               withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                               withVisualId:rootVisual
                                              withValueMask:0
                                              withValueList:NULL];
    
    [minizeWindowButton createGraphicContext];
    
    maximizeWindowButton = [aConnection createWindowWithDepth:XCB_COPY_FROM_PARENT
                                             withParentWindow:self
                                                withXPosition:37
                                                withYPosition:5
                                                    withWidth:10
                                                   withHeight:10
                                             withBorrderWidth:1
                                                 withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                 withVisualId:rootVisual
                                                withValueMask:0
                                                withValueList:NULL];
    
    [maximizeWindowButton createGraphicContext];
    
    [aConnection mapWindow:self];
    [aConnection mapWindow:hideWindowButton];
    [aConnection mapWindow:minizeWindowButton];
    [aConnection mapWindow:maximizeWindowButton];
    
    
    return self;
}

- (void) dealloc
{
    hideWindowButton = nil;
    minizeWindowButton = nil;
    maximizeWindowButton = nil;
}


@end
