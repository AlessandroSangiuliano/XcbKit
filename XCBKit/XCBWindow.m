//
//  XCBWindow.m
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBWindow.h"
#import "XCBConnection.h"
#import "XCBTitleBar.h"
#import "services/XCBAtomService.h"
#import "functions/Transformers.h"
#import "utils/CairoDrawer.h"
#import "services/EWMHService.h"

#define BUTTONMASK  (XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE)

@implementation XCBWindow

@synthesize graphicContextId;
@synthesize windowRect;
@synthesize originalRect;
@synthesize decorated;
@synthesize isCloseButton;
@synthesize isMinimizeButton;
@synthesize isMaximizeButton;
@synthesize oldRect;
@synthesize isMaximized;
@synthesize isMinimized;
@synthesize connection;
@synthesize needDestroy;
@synthesize pixmap;
@synthesize pointerGrabbed;
@synthesize firstRun;
@synthesize allowedActions;
@synthesize canMove;
@synthesize canResize;
@synthesize canMinimize;
@synthesize canMaximizeVert;
@synthesize canMaximizeHorz;
@synthesize canFullscreen;
@synthesize canChangeDesktop;
@synthesize canClose;
@synthesize canShade;
@synthesize canStick;
@synthesize isAbove;
@synthesize pixmapSize;

- (id) initWithXCBWindow:(xcb_window_t)aWindow
           andConnection:(XCBConnection *)aConnection
{
	return [self initWithXCBWindow:aWindow
				  withParentWindow:XCB_NONE
				   withAboveWindow:XCB_NONE
                    withConnection:aConnection];
}

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow *) aParent
           andConnection:(XCBConnection *)aConnection
{
	return [self initWithXCBWindow:aWindow
				  withParentWindow:aParent
				   withAboveWindow:XCB_NONE
                    withConnection:aConnection];
}

- (id) initWithXCBWindow:(xcb_window_t) aWindow
		withParentWindow:(XCBWindow *) aParent
		 withAboveWindow:(XCBWindow *) anAbove
          withConnection:(XCBConnection*)aConnection
{
	self = [super init];
	window = aWindow;
	parentWindow = aParent;
	aboveWindow = anAbove;
	isMapped = NO;
    decorated = NO;
    isCloseButton = NO;
    isMinimizeButton = NO;
    isMaximizeButton = NO;
    connection = aConnection;
    needDestroy = NO;
    canMove = NO;
    canResize = NO;
    canMinimize = NO;
    canMaximizeVert = NO;
    canMaximizeHorz = NO;
    canFullscreen = NO;
    canShade = NO;
    canStick = NO;
    canChangeDesktop = NO;
    canClose = NO;

    /*** checks _net_wm_allowed_action for client window ***/

    [NSThread detachNewThreadSelector:@selector(checkNetWMAllowedActions) toTarget:self withObject:nil];

	return self;
}

- (xcb_void_cookie_t) createGraphicContextWithMask:(uint32_t)aMask andValues:(uint32_t *)theValues
{
    graphicContextId = xcb_generate_id([connection connection]);
    xcb_void_cookie_t gcCookie = xcb_create_gc([connection connection],
                                               graphicContextId,
                                               window,
                                               aMask,
                                               theValues);
    return gcCookie;

}

- (void) destroyGraphicsContext
{
    xcb_free_gc([connection connection], graphicContextId);
}

- (void) checkNetWMAllowedActions
{
    EWMHService* ewmhService = [EWMHService sharedInstanceWithConnection:connection];

    xcb_atom_t* allowed_actions = [ewmhService getProperty:[ewmhService EWMHWMAllowedActions]
                                              propertyType:XCB_ATOM_ATOM
                                                 forWindow:self
                                                    delete:NO];

    int allowedActionSize = 0;

    (allowed_actions != NULL) ? (allowedActionSize = sizeof(allowed_actions)/sizeof(allowed_actions[0])) : (allowedActionSize = 0);

    if (allowedActionSize > 0)
    {
        allowedActions = [[NSMutableArray alloc] initWithCapacity:allowedActionSize];

        for (int i = 0; i < allowedActionSize; i++)
        {
            NSNumber* number = [NSNumber numberWithUnsignedInt:allowed_actions[i]];
            [allowedActions addObject:number];
            number = nil;
        }

        free(allowed_actions);
    }

    if (allowed_actions == NULL)
    {
        canMove = YES;
        canResize = YES;
        canMinimize = YES;
        canMaximizeVert = YES;
        canMaximizeHorz = YES;
        canFullscreen = YES;
        canShade = YES;
        canStick = YES;
        canChangeDesktop = YES;
        canClose = YES;

        ewmhService = nil;
        return;
    }

    XCBAtomService *atomService = [ewmhService atomService];

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionClose]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canClose = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionFullscreen]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canFullscreen = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionChangeDesktop]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canChangeDesktop = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionMaximizeHorz]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canMaximizeHorz = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionMaximizeVert]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canMaximizeVert = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionMinimize]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canMinimize = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionMove]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canMove = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionStick]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canStick = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionShade]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canShade = YES;

    for (int i = 0; i < [allowedActions count]; i++)
        if ([atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMActionResize]] ==
            [[allowedActions objectAtIndex:i] unsignedIntegerValue])

            canResize = YES;

    ewmhService = nil;
    atomService = nil;

}

- (void) createPixmap
{
    pixmap = xcb_generate_id([connection connection]);
    XCBScreen* screen = [[connection screens] objectAtIndex:0];
    //sleep(1);

    uint32_t mask = XCB_GC_FOREGROUND | XCB_GC_BACKGROUND | XCB_GC_GRAPHICS_EXPOSURES;
	uint32_t values[] = {[screen screen]->white_pixel, [screen screen]->white_pixel, 0};
	[self createGraphicContextWithMask:mask andValues:values];

    xcb_create_pixmap([connection connection],
                      [screen screen]->root_depth,
                      pixmap,
                      window,
                      windowRect.size.width,
                      windowRect.size.height);
    
    pixmapSize = XCBMakeSize(windowRect.size.width, windowRect.size.height);

    xcb_rectangle_t expose_rectangle = FnFromXCBRectToXcbRectangle(windowRect);

    xcb_rectangle_t rectangles[] = {expose_rectangle};

    xcb_poly_fill_rectangle([connection connection], pixmap, graphicContextId, 1, rectangles);

    xcb_copy_area([connection connection],
                  window,
                  pixmap,
                  graphicContextId,
                  0,
                  0,
                  0,
                  0,
                  windowRect.size.width,
                  windowRect.size.height);

    /*XCBVisual* visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:self  visual:visual];

    [drawer drawContent];*/
    screen = nil;
}

- (void) createPixmapDelayed
{
    [NSThread sleepForTimeInterval:1];
    [self createPixmap];
}

- (void) updatePixmap
{
    if (pixmap == 0)
    {
        NSLog(@"Pixmap not allocated");
        return;
    }

    xcb_rectangle_t expose_rectangle = FnFromXCBRectToXcbRectangle(windowRect);

    xcb_rectangle_t rectangles[] = {expose_rectangle};

    xcb_poly_fill_rectangle([connection connection], pixmap, graphicContextId, 1, rectangles);
    xcb_copy_area([connection connection],
                  window,
                  pixmap,
                  graphicContextId,
                  0,
                  0,
                  0,
                  0,
                  windowRect.size.width,
                  windowRect.size.height);
    
    pixmapSize = XCBMakeSize(windowRect.size.width, windowRect.size.height);

    /** FIXME: REMEMBER TO DELETE ALL THIS */

    /*XCBScreen* screen = [[connection screens] objectAtIndex:0];
    XCBVisual* visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    CairoDrawer *drawer = [[CairoDrawer alloc] initWithConnection:connection window:self  visual:visual];

    [drawer drawContent];*/
}

- (void) destroyPixmap
{
    if (pixmap == 0)
    {
        NSLog(@"Pixmap Not allocated");
        return;
    }

    xcb_free_pixmap([connection connection], pixmap);
}
- (xcb_window_t) window
{
	return window;
}

- (void) setWindow:(xcb_window_t )aWindow
{
	window = aWindow;
}

- (NSString*) windowIdStringValue
{
	NSString *stringId = [NSString stringWithFormat:@"%u", window];
	return stringId;
}

- (XCBWindow*) parentWindow
{
	return parentWindow;
}

- (XCBWindow*) aboveWindow
{
	return aboveWindow;
}

- (void) setParentWindow:(XCBWindow *)aParent
{
	parentWindow = aParent;
}

- (void) setAboveWindow:(XCBWindow *)anAbove
{
	aboveWindow = anAbove;
}

- (void) setIsMapped:(BOOL) mapped
{
	isMapped = mapped;
}

- (BOOL) isMapped
{
	return isMapped;
}

- (xcb_get_window_attributes_reply_t) attributes
{
	return attributes;
}

- (void) setAttributes:(xcb_get_window_attributes_reply_t)someAttributes
{
	attributes = someAttributes;
}

- (uint32_t) windowMask
{
    return windowMask;
}

- (void) setWindowMask:(uint32_t)aMask
{
    windowMask = aMask;
}

- (void) setWindowBorderWidth:(uint32_t)border
{
    uint16_t tempMask = XCB_CONFIG_WINDOW_BORDER_WIDTH;
    uint32_t valueForBorder[1] = {border};

    xcb_configure_window([connection connection], window, tempMask, valueForBorder);
}

- (void) restoreDimensionAndPosition
{
    XCBFrame* frame = (XCBFrame*) [parentWindow parentWindow];
    XCBTitleBar* titleBar;

    if ([parentWindow isKindOfClass:[XCBTitleBar class]])
    {
        titleBar = (XCBTitleBar*)parentWindow;
    }


    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;

    /*** restore to the previous dimension and position of the frame ***/

    [frame setWindowRect:[frame originalRect]];
    [frame setOldRect:XCBInvalidRect];

    uint32_t valueList[4] =
    {
        [frame windowRect].position.x,
        [frame windowRect].position.y,
        [frame windowRect].size.width,
        [frame windowRect].size.height
    };

    xcb_configure_window([connection connection], [frame window], mask, &valueList);

    /*** restore the title bar pos and dim ***/

    [titleBar setWindowRect:[titleBar oldRect]];
    [titleBar setOldRect:XCBInvalidRect];
    valueList[0] = [titleBar windowRect].position.x;
    valueList[1] = [titleBar windowRect].position.y;
    valueList[2] = [titleBar windowRect].size.width;
    valueList[3] = [titleBar windowRect].size.height;

    xcb_configure_window([connection connection], [titleBar window], mask, &valueList);

    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

    /*** restore dim and pos of the client window ***/

    XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];

    [clientWindow setWindowRect:[clientWindow originalRect]];
    [clientWindow setOldRect:XCBInvalidRect];
    valueList[0] = [clientWindow windowRect].position.x;
    valueList[1] = [clientWindow windowRect].position.y;
    valueList[2] = [clientWindow windowRect].size.width;
    valueList[3] = [clientWindow windowRect].size.height;

    xcb_configure_window([connection connection], [clientWindow window], mask, &valueList);

    [frame setIsMaximized:NO];

    EWMHService* ewmhService = [connection ewmhService];
    XCBAtomService* atomService = [ewmhService atomService];

    xcb_atom_t state[1] = {ICCCM_WM_STATE_NORMAL};
    [atomService cacheAtom:@"WM_STATE"];

    [ewmhService changePropertiesForWindow:frame
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:@"WM_STATE"
                                  withType:XCB_ATOM_ATOM
                                withFormat:32
                            withDataLength:1
                                  withData:state];

    /*** what i should set fow ewmh? iconifying a window will set _NET_WM_STATE to _HIDDEN as required by EWMH docs, and IconicState for ICCCM.
     The docs are not saying what I should set after restoring a window from iconified for EWMH,
     but the ICCCM says I have to set WM_STATE to NormalState as I do above ****/

    titleBar = nil;
    clientWindow = nil;
    frame = nil;
    ewmhService = nil;
    atomService = nil;

    return;
}

- (void) maximizeToWidth:(uint16_t)width andHeight:(uint16_t)height
{
    XCBFrame* frame = (XCBFrame*) [parentWindow parentWindow];
    XCBTitleBar* titleBar;

    if ([frame isMaximized])
    {
        [self restoreDimensionAndPosition];
        return;
    }

    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;


    if ([parentWindow isKindOfClass:[XCBTitleBar class]])
    {
        titleBar = (XCBTitleBar*)parentWindow;
    }

    /*** save previous dimensions and position of the window **/

    [frame setOldRect:[frame windowRect]];


    /*** redraw and resize the frame ***/

    uint32_t valueList[4] = {0, 0, width-2, height-2};

    xcb_configure_window([connection connection], [frame window], mask, &valueList);

    /*** set the new position and window rect dimension for the frame ***/

    XCBSize newSize = XCBMakeSize(width-2, height-2);
    XCBPoint newPoint = XCBMakePoint(0, 0);
    XCBRect newRect = XCBMakeRect(newPoint, newSize);
    [frame setWindowRect:newRect];

    /*** resize the title bar and save the old rect ***/

    [titleBar setOldRect:[titleBar windowRect]];

    uint16_t oldHeight = [titleBar windowRect].size.height;

    newSize = XCBMakeSize(width-2, oldHeight);
    newPoint = XCBMakePoint(0, 0);
    newRect = XCBMakeRect(newPoint, newSize);

    valueList[3] = [titleBar windowRect].size.height;

    xcb_configure_window([connection connection], [titleBar window], mask, &valueList);

    /*** set the new title bar rect and redraw it ***/

    [titleBar setWindowRect:newRect];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];


    /*** resize the client window and save the old rect ***/

    XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];

    [clientWindow setOldRect:[clientWindow windowRect]];

    valueList[0] = 0;
    valueList[1] = 23;
    valueList[2] = width-2;
    valueList[3] = height-2;

    xcb_configure_window([connection connection], [clientWindow window], mask, &valueList);

    /*** set the new position and dimensions of the client window ***/

    newSize = XCBMakeSize(width-2, height-2);
    newPoint = XCBMakePoint(0, 23);
    newRect = XCBMakeRect(newPoint, newSize);

    [clientWindow setWindowRect:newRect];

    [frame setIsMaximized:YES];

    EWMHService* ewmhSerive = [connection ewmhService];
    XCBAtomService* atomService = [ewmhSerive atomService];

    xcb_atom_t state[2] =
    {
        [atomService atomFromCachedAtomsWithKey:[ewmhSerive EWMHWMStateMaximizedVert]],
        [atomService atomFromCachedAtomsWithKey:[ewmhSerive EWMHWMStateMaximizedHorz]]
    };

    [ewmhSerive changePropertiesForWindow:frame
                                 withMode:XCB_PROP_MODE_REPLACE
                             withProperty:[ewmhSerive EWMHWMState]
                                 withType:XCB_ATOM_ATOM
                               withFormat:32
                           withDataLength:2
                                 withData:state];
    
    titleBar = nil;
    clientWindow = nil;
    frame = nil;
    atomService = nil;
    ewmhSerive = nil;

    return;
}

- (void) minimize
{
    XCBAtomService* atomService =  [XCBAtomService sharedInstanceWithConnection:connection];
    xcb_atom_t changeStateAtom = [atomService cacheAtom:@"WM_CHANGE_STATE"];
    XCBScreen* screen = [[connection screens] objectAtIndex:0];


    /*** TODO: check if the if the window is already miniaturized ***/

    xcb_client_message_event_t event;

    event.response_type = XCB_CLIENT_MESSAGE;
    event.format = 32;
    event.sequence = 0;
    event.window = window;
    event.type = changeStateAtom;
    event.data.data32[0] = ICCCM_WM_STATE_ICONIC;
    event.data.data32[1] = 0;
    event.data.data32[2] = 0;
    event.data.data32[3] = 0;
    event.data.data32[4] = 0;

    xcb_send_event([connection connection], 0,
                   [[screen rootWindow] window],
                   XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT,
                   (const char*) &event);

    /*** set iconic hints? or normal if not iconized hints? ***/

    atomService = nil;
    screen = nil;

}

- (void) createMiniWindowAtPosition:(XCBPoint)position
{
    oldRect = windowRect;
    XCBTitleBar* titleBar;

    XCBSize newSize = XCBMakeSize(50, 50); //misure di prova
    XCBRect newRect = XCBMakeRect(position, newSize);

    windowRect = newRect;

    if ([self isKindOfClass:[XCBFrame class]])
    {
        XCBFrame* frameWindow = (XCBFrame*) self;
        XCBWindow* clientWindow = [frameWindow childWindowForKey:ClientWindow];
        XCBTitleBar* titleBar = (XCBTitleBar*) [frameWindow childWindowForKey:TitleBar];

        [clientWindow setOldRect:[clientWindow windowRect]];
        [titleBar description];
        [titleBar setOldRect:[titleBar windowRect]];

        frameWindow = nil;
        clientWindow = nil;
        titleBar = nil;
    }

    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    uint32_t valueList[4] = {position.x, position.y, newSize.width, newSize.height};

    xcb_configure_window([connection connection], window, mask, &valueList);

    if ([self isKindOfClass:[XCBFrame class]])
    {
        XCBFrame* frame = (XCBFrame*)self;
        titleBar = (XCBTitleBar*) [frame childWindowForKey:TitleBar];
        [titleBar setOldRect:[titleBar windowRect]];
    }

    EWMHService* ewmhService = [connection ewmhService];
    XCBAtomService* atomService = [ewmhService atomService];
    [atomService cacheAtom:@"WM_STATE"];

    xcb_atom_t state[1] = {[atomService atomFromCachedAtomsWithKey:[ewmhService EWMHWMStateHidden]]};

    [ewmhService changePropertiesForWindow:self
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:[ewmhService EWMHWMState]
                                  withType:XCB_ATOM_ATOM
                                withFormat:32
                            withDataLength:1
                                  withData:state];

    state[0] = ICCCM_WM_STATE_ICONIC;

    [ewmhService changePropertiesForWindow:self
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:@"WM_STATE"
                                  withType:XCB_ATOM_ATOM
                                withFormat:32
                            withDataLength:1
                                  withData:state];

    atomService = nil;
    ewmhService = nil;
    titleBar = nil;

    isMinimized = YES;

    return;
}

- (void) restoreFromIconified
{
    windowRect = oldRect;
    XCBFrame* frame;

    EWMHService* ewmhService = [connection ewmhService];
    XCBAtomService* atomService = [ewmhService atomService];

    xcb_atom_t state[1] = {ICCCM_WM_STATE_NORMAL};
    [atomService cacheAtom:@"WM_STATE"];

    XCBPoint position = windowRect.position;
    XCBSize size =  windowRect.size;

    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    uint32_t valueList[4] = {position.x, position.y, size.width, size.height};

    xcb_configure_window([connection connection], window, mask, &valueList);

    // TODO: ripristinate eventual mask values

    if ([self isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame*)self;
        XCBTitleBar* titleBar = (XCBTitleBar*)[frame childWindowForKey:TitleBar];
        XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];

        [titleBar setWindowRect:[titleBar oldRect]];
        [clientWindow setWindowRect:[clientWindow oldRect]];
        [connection mapWindow:titleBar];

        [titleBar description];
        [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

        [connection mapWindow:clientWindow];
        [clientWindow setIsMinimized:NO];

        [ewmhService changePropertiesForWindow:clientWindow
                                      withMode:XCB_PROP_MODE_REPLACE
                                  withProperty:@"WM_STATE"
                                      withType:XCB_ATOM_ATOM
                                    withFormat:32
                                withDataLength:1
                                      withData:state];

        titleBar = nil;
        clientWindow = nil;
        frame = nil;
    }

    isMinimized = NO;

    [ewmhService changePropertiesForWindow:frame
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:@"WM_STATE"
                                  withType:XCB_ATOM_ATOM
                                withFormat:32
                            withDataLength:1
                                  withData:state];

    ewmhService = nil;
    atomService = nil;
    frame = nil;
}

- (void) destroy
{
    xcb_destroy_window([connection connection], window);
    [connection unregisterWindow:self];
    [connection setNeedFlush:YES];
}

- (void) hide
{
    [connection unmapWindow:self];
    [connection setNeedFlush:YES];
}

- (void) stackAbove
{
    uint32_t values[1] = {XCB_STACK_MODE_ABOVE};
    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_STACK_MODE, &values);
    isAbove = YES;
}

- (void) stackBelow
{
    uint32_t values[1] = {XCB_STACK_MODE_BELOW};
    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_STACK_MODE, &values);
    isAbove = NO;
}

- (void) grabButton
{
    if (firstRun)
    {
        firstRun = NO;
        return;
    }

    xcb_ungrab_button([connection connection], XCB_BUTTON_INDEX_ANY, window, XCB_BUTTON_MASK_ANY);

    xcb_grab_button([connection connection],
                    YES,
                    window,
                    BUTTONMASK,
                    XCB_GRAB_MODE_ASYNC,
                    XCB_GRAB_MODE_ASYNC,
                    XCB_NONE,
                    XCB_NONE,
                    XCB_BUTTON_INDEX_1, //for now just grab the left button
                    XCB_MOD_MASK_ANY); // for now any mask.
}

- (void) ungrabButton
{
    xcb_ungrab_button([connection connection], XCB_BUTTON_INDEX_ANY, window, XCB_BUTTON_MASK_ANY);
}

- (BOOL) grabPointer
{
    uint16_t mask = XCB_EVENT_MASK_BUTTON_MOTION | XCB_EVENT_MASK_POINTER_MOTION;
    xcb_grab_pointer_reply_t* reply = xcb_grab_pointer_reply([connection connection],
                                                             xcb_grab_pointer([connection connection],
                                                                              0,
                                                                              window,
                                                                              BUTTONMASK | mask,
                                                                              XCB_GRAB_MODE_ASYNC,
                                                                              XCB_GRAB_MODE_ASYNC,
                                                                              XCB_NONE,
                                                                              XCB_NONE,
                                                                              XCB_CURRENT_TIME), NULL);

    if (!reply || reply->status != XCB_GRAB_STATUS_SUCCESS)
        return NO;

    pointerGrabbed = YES;
    //NSLog(@"Pointer grabbed");
    return YES;

}

- (void) ungrabPointer
{
    if (pointerGrabbed)
    {
        xcb_ungrab_pointer([connection connection], XCB_CURRENT_TIME);
        pointerGrabbed = NO;
        //NSLog(@"Pointer ungrabbed");
    }
}


- (void) description
{
    NSLog(@" Window id: %u. Parent window id: %u.\nWindow %@", window, [parentWindow window], FnFromXCBRectToString(windowRect));
}

- (void) dealloc
{
    parentWindow = nil;
    aboveWindow = nil;
    [allowedActions removeAllObjects];
    allowedActions = nil;
}

@end
