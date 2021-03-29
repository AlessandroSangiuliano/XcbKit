//
//  XCBTitleBar.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 06/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBTitleBar.h"
#import "utils/CairoDrawer.h"

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
@synthesize titleIsSet;


- (id) initWithFrame:(XCBFrame *)aFrame withConnection:(XCBConnection *)aConnection
{
    self = [super init];

    if (self == nil)
        return nil;

    windowMask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    [super setConnection:aConnection];

    ewmhService = [EWMHService sharedInstanceWithConnection:[super connection]];
    titleIsSet = NO;
    
    return self;
}

- (void) drawArcsForColor:(TitleBarColor)aColor
{
    XCBColor stopColor = XCBMakeColor(1,1,1,1);
    XCBWindow *rootWindow = [parentWindow parentWindow];
    XCBScreen *scr = [rootWindow screen];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[scr screen]->root_visual];
    NSBundle *thisBundle = [NSBundle bundleForClass:[self class]];
    [visual setVisualTypeForScreen:scr];

    CairoDrawer *drawer = nil;
    
    if (hideWindowButton != nil)
    {
        NSString* path = [thisBundle pathForResource:@"close" ofType:@"png"];
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:hideWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor:aColor == TitleBarUpColor ? hideButtonColor : titleBarDownColor withStopColor:stopColor];
        [drawer putImage:path];
        
        drawer = nil;
        path= nil;
    }
    
    if (minimizeWindowButton != nil)
    {
        NSString* path = [thisBundle pathForResource:@"min" ofType:@"png"];
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:minimizeWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? minimizeButtonColor : titleBarDownColor  withStopColor:stopColor];
        [drawer putImage:path];
        
        drawer = nil;
        path = nil;
    }
    
    if (maximizeWindowButton != nil)
    {
        NSString* path = [thisBundle pathForResource:@"max" ofType:@"png"];
        drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:maximizeWindowButton visual:visual];
        
        [drawer drawTitleBarButtonWithColor: aColor == TitleBarUpColor ? maximizeButtonColor : titleBarDownColor  withStopColor:stopColor];
        [drawer putImage:path];

        path = nil;
        drawer = nil;
    }
    
    scr = nil;
    visual = nil;
    rootWindow = nil;
    thisBundle = nil;
}

- (void) drawTitleBarForColor:(TitleBarColor)aColor
{
    XCBColor aux;
    
    if (aColor == TitleBarUpColor)
        aux = titleBarUpColor;
    
    if (aColor == TitleBarDownColor)
        aux = titleBarDownColor;
    
    XCBScreen *screen = [self onScreen];
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
        //[drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    if (minimizeWindowButton != nil)
    {
        [drawer setWindow:minimizeWindowButton];
        [drawer setHeight:[minimizeWindowButton windowRect].size.height];
        [drawer setWidth:[minimizeWindowButton windowRect].size.width];
        //[drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    if (maximizeWindowButton != nil)
    {
        [drawer setWindow:maximizeWindowButton];
        [drawer setHeight:[maximizeWindowButton windowRect].size.height];
        [drawer setWidth:[maximizeWindowButton windowRect].size.width];
        //[drawer drawWindowWithColor:aux andStopColor:stopColor];
    }
    
    drawer = nil;
    screen = nil;
    visual = nil;
}

- (void) generateButtons
{
    XCBWindow *rootWindow = [parentWindow parentWindow];
    XCBScreen *screen = [rootWindow screen];
    XCBVisual *rootVisual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];

    [rootVisual setVisualTypeForScreen:screen];
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS;

    BOOL shapeExtensionSupported;

    XCBFrame* frame = (XCBFrame*)parentWindow;

    if ([[frame childWindowForKey:ClientWindow] canClose])
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

        shapeExtensionSupported = [[hideWindowButton shape] checkSupported];
        [[hideWindowButton shape] calculateDimensionsFromGeometries:[hideWindowButton geometries]];

        if (shapeExtensionSupported)
        {
            [[hideWindowButton shape] createPixmapsAndGCs];
            [[hideWindowButton shape] createArcsWithRadius:7];
        }
        else
            NSLog(@"Shape extension not supported for window: %u", [hideWindowButton window]);

    }

    if ([[frame childWindowForKey:ClientWindow] canMinimize])
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

        [minimizeWindowButton setWindowMask:mask];
        [minimizeWindowButton setCanMove:NO];
        [minimizeWindowButton setIsMinimizeButton:YES];

        minimizeButtonColor = XCBMakeColor(0.9,0.7,0.3,1);

        shapeExtensionSupported = [[minimizeWindowButton shape] checkSupported];
        [[minimizeWindowButton shape] calculateDimensionsFromGeometries:[minimizeWindowButton geometries]];

        if (shapeExtensionSupported)
        {
            [[minimizeWindowButton shape] createPixmapsAndGCs];
            [[minimizeWindowButton shape] createArcsWithRadius:7];
        }
        else
            NSLog(@"Shape extension not supported for window: %u", [minimizeWindowButton window]);

    }

    if ([[frame childWindowForKey:ClientWindow] canFullscreen])
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

        [maximizeWindowButton setWindowMask:mask];
        [maximizeWindowButton setCanMove:NO];
        [maximizeWindowButton setIsMaximizeButton:YES];

        maximizeButtonColor = XCBMakeColor(0,0.74,1,1);

        shapeExtensionSupported = [[maximizeWindowButton shape] checkSupported];
        [[maximizeWindowButton shape] calculateDimensionsFromGeometries:[maximizeWindowButton geometries]];

        if (shapeExtensionSupported)
        {
            [[maximizeWindowButton shape] createPixmapsAndGCs];
            [[maximizeWindowButton shape] createArcsWithRadius:7];
        }
        else
            NSLog(@"Shape extension not supported for window: %u", [maximizeWindowButton window]);
    }

    [[super connection] mapWindow:hideWindowButton];
    [[super connection] mapWindow:minimizeWindowButton];
    [[super connection] mapWindow:maximizeWindowButton];

    screen = nil;
    rootVisual = nil;
    rootWindow = nil;
    frame = nil;
}

- (void) drawTitleBarComponentsForColor:(TitleBarColor)aColor
{
    [self drawTitleBarForColor:aColor];
    //[self drawArcsForColor:aColor];
    [self setWindowTitle:windowTitle];
}

- (void) setWindowTitle:(NSString *) title
{
    if (titleIsSet)
        return;

    windowTitle = title;

    if ([title length] == 0)
    {
        NSLog(@"No title to set to the window.");
        return;
    }

    XCBWindow *rootWindow = [parentWindow parentWindow];
    XCBScreen *screen = [rootWindow screen];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:[super connection] window:self visual:visual];
    XCBColor black = XCBMakeColor(0,0,0,1);
    [drawer drawText:windowTitle withColor:black];
    titleIsSet = YES;
    
    drawer = nil;
    screen = nil;
    visual = nil;
    rootWindow = nil;
}

- (NSString*) windowTitle
{
    return windowTitle;
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
