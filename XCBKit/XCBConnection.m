//
//  XCBConnection.m
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBConnection.h"
#import "services/EWMHService.h"
#import "XCBFrame.h"
#import "XCBSelection.h"
#import "XCBTitleBar.h"
#import "functions/Transformers.h"
#import "utils/CairoDrawer.h"
#import "services/ICCCMService.h"
#import "XCBRegion.h"
#import "XCBGeometryReply.h"
#import "utils/CairoSurfacesSet.h"
#import <xcb/xcb_aux.h>
#import "XCBAttributesReply.h"

@implementation XCBConnection

@synthesize dragState;
@synthesize damagedRegions;
@synthesize xfixesInitialized;
@synthesize resizeState;

XCBConnection *XCBConn;
ICCCMService *icccmService;

- (id)init
{
    return [self initWithDisplay:NULL];
}

- (id)initWithDisplay:(NSString *)aDisplay
{
    self = [super init];
    const char *localDisplayName = NULL;
    needFlush = NO;
    dragState = NO;

    if (aDisplay == NULL)
    {
        NSLog(@"[XCBConnection] Connecting to the default display in env DISPLAY");
    } else
    {
        NSLog(@"XCBConnection: Creating connection with display: %@", aDisplay);
        localDisplayName = [aDisplay UTF8String];
    }

    windowsMap = [[NSMutableDictionary alloc] initWithCapacity:1000];

    screens = [NSMutableArray new];

    connection = xcb_connect(localDisplayName, NULL);

    if (connection == NULL)
    {
        NSLog(@"Connection FAILED");
        self = nil;
        return nil;
    }

    if (xcb_connection_has_error(connection))
    {
        NSLog(@"Connection has ERROR");
        self = nil;
        return nil;
    }

    int fd = xcb_get_file_descriptor(connection);

    NSLog(@"XCBConnection: Connection: %d", fd);

    /** save all screens **/

    [self checkScreens];

    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:self];
    currentTime = XCB_CURRENT_TIME;
    icccmService = [ICCCMService sharedInstanceWithConnection:self];

    XCBConn = self;
    resizeState = NO;
    ewmhService = nil;
    [self flush];
    return self;
}

+ (XCBConnection *)sharedConnection
{
    static XCBConnection *sharedInstance = nil;

    if (XCBConn == nil)
    {
        NSLog(@"[XCBConnection]: Creating shared connection...");
        sharedInstance = [[self alloc] init];
    }

    return XCBConn;
}

- (xcb_connection_t *)connection
{
    return connection;
}

- (NSMutableDictionary *)windowsMap
{
    return windowsMap;
}

- (void)registerWindow:(XCBWindow *)aWindow
{
    NSLog(@"[XCBConnection] Adding the window %u in the windowsMap", [aWindow window]);
    NSNumber *key = [[NSNumber alloc] initWithInt:[aWindow window]];
    XCBWindow *window = [windowsMap objectForKey:key];

    if (window != nil)
    {
        NSLog(@"Window %u previously added", [window window]);
        window = nil;
        key = nil;
        return;
    }

    [windowsMap setObject:aWindow forKey:key];
    window = nil;
    key = nil;
}

- (void)unregisterWindow:(XCBWindow *)aWindow
{
    NSLog(@"[XCBConnection] Removing the window %u from the windowsMap", [aWindow window]);
    NSNumber *key = [[NSNumber alloc] initWithInt:[aWindow window]];
    [windowsMap removeObjectForKey:key];
    key = nil;
}

- (void)closeConnection
{
    xcb_disconnect(connection);
}

- (XCBWindow *)windowForXCBId:(xcb_window_t)anId
{
    NSNumber *key = [NSNumber numberWithInt:anId];
    XCBWindow *window = [windowsMap objectForKey:key];
    key = nil;
    return window;
}

- (int)flush
{
    int flushResult = xcb_flush(connection);
    needFlush = NO;
    return flushResult;
}

- (void)setNeedFlush:(BOOL)aNeedFlushChoice
{
    needFlush = aNeedFlushChoice;
}

- (void) checkScreens
{
    xcb_screen_iterator_t iterator = xcb_setup_roots_iterator(xcb_get_setup(connection));
    NSUInteger number = 0;

    while (iterator.rem)
    {
        xcb_screen_t *scr = iterator.data;
        XCBWindow *rootWindow = [[XCBWindow alloc] initWithXCBWindow:scr->root withParentWindow:XCB_NONE andConnection:self];
        XCBScreen *screen = [XCBScreen screenWithXCBScreen:scr andRootWindow:rootWindow];
        [screen setScreenNumber:number++];
        [screens addObject:screen];

        NSLog(@"[XCBConnection] Screen with root window: %d;\n\
			  With width in pixels: %d;\n\
			  With height in pixels: %d\n",
              scr->root,
              scr->width_in_pixels,
              scr->height_in_pixels);

        [self registerWindow:rootWindow];
        [rootWindow setScreen:screen];
        xcb_screen_next(&iterator);
        rootWindow = nil;
        screen = nil;
    }

    NSLog(@"Number of screens: %lu", (unsigned long) [screens count]);
}

- (NSMutableArray *)screens
{
    return screens;
}

- (XCBWindowTypeResponse *)createWindowForRequest:(XCBCreateWindowTypeRequest *)aRequest registerWindow:(BOOL)reg
{
    XCBWindow *window;
    XCBFrame *frame;
    XCBTitleBar *titleBar;
    XCBWindowTypeResponse *response;

    window = [self createWindowWithDepth:[aRequest depth]
                        withParentWindow:[aRequest parentWindow]
                           withXPosition:[aRequest xPosition]
                           withYPosition:[aRequest yPosition]
                               withWidth:[aRequest width]
                              withHeight:[aRequest height]
                        withBorrderWidth:[aRequest borderWidth]
                            withXCBClass:[aRequest xcbClass]
                            withVisualId:[aRequest visual]
                           withValueMask:[aRequest valueMask]
                           withValueList:[aRequest valueList]];

    if ([aRequest windowType] == XCBWindowRequest)
    {
        response = [[XCBWindowTypeResponse alloc] initWithXCBWindow:window];
    }

    if ([aRequest windowType] == XCBFrameRequest)
    {
        frame = FnFromXCBWindowToXCBFrame(window, self, [aRequest clientWindow]);

        if (reg)
        {
            [self unregisterWindow:window];
            [self registerWindow:frame];
        } else
            [self unregisterWindow:window];

        response = [[XCBWindowTypeResponse alloc] initWithXCBFrame:frame];
    }

    if ([aRequest windowType] == XCBTitleBarRequest)
    {
        titleBar = FnFromXCBWindowToXCBTitleBar(window, self);
        response = [[XCBWindowTypeResponse alloc] initWithXCBTitleBar:titleBar];

        if (reg)
        {
            [self unregisterWindow:window];
            [self registerWindow:titleBar];
        } else
            [self unregisterWindow:window];

    }

    frame = nil;
    titleBar = nil;
    window = nil;

    return response;
}

- (XCBWindow *)createWindowWithDepth:(uint8_t)depth
                    withParentWindow:(XCBWindow *)aParentWindow
                       withXPosition:(int16_t)xPosition
                       withYPosition:(int16_t)yPosition
                           withWidth:(int16_t)width
                          withHeight:(int16_t)height
                    withBorrderWidth:(uint16_t)borderWidth
                        withXCBClass:(uint16_t)xcbClass
                        withVisualId:(XCBVisual *)aVisual
                       withValueMask:(uint32_t)valueMask
                       withValueList:(const uint32_t *)valueList
{
    xcb_window_t winId = xcb_generate_id(connection);
    XCBWindow *winToCreate = [[XCBWindow alloc] initWithXCBWindow:winId withParentWindow:aParentWindow andConnection:self];

    XCBPoint coordinates = XCBMakePoint(xPosition, yPosition);
    XCBSize windowSize = XCBMakeSize(width, height);
    XCBRect windowRect = XCBMakeRect(coordinates, windowSize);

    [winToCreate setWindowRect:windowRect];
    [winToCreate setOriginalRect:windowRect];

    xcb_create_window(connection,
                      depth,
                      winId,
                      [aParentWindow window],
                      [winToCreate windowRect].position.x,
                      [winToCreate windowRect].position.y,
                      [winToCreate windowRect].size.width,
                      [winToCreate windowRect].size.height,
                      borderWidth,
                      xcbClass,
                      [aVisual visualId],
                      valueMask,
                      valueList);


    needFlush = YES;
    [self registerWindow:winToCreate];
    return winToCreate;

}

- (void)mapWindow:(XCBWindow *)aWindow
{
    xcb_map_window(connection, [aWindow window]);
    [aWindow setIsMapped:YES];
}

- (void)unmapWindow:(XCBWindow *)aWindow
{
    xcb_unmap_window(connection, [aWindow window]);
    [aWindow setIsMapped:NO];
}

- (void)reparentWindow:(XCBWindow *)aWindow toWindow:(XCBWindow *)parentWindow position:(XCBPoint)position
{
    xcb_reparent_window(connection, [aWindow window], [parentWindow window], position.x, position.y);
    XCBRect newRect = XCBMakeRect(XCBMakePoint(position.x, position.y),
                                  XCBMakeSize([aWindow windowRect].size.width, [aWindow windowRect].size.height));

    [aWindow setWindowRect:newRect];
    [aWindow setOriginalRect:newRect];
    [aWindow setParentWindow:parentWindow];
}

- (BOOL)changeAttributes:(uint32_t[])values forWindow:(XCBWindow *)aWindow withMask:(uint32_t)aMask checked:(BOOL)check
{
    xcb_void_cookie_t cookie;

    BOOL attributesChanged = NO;

    NSLog(@"Changing attributes for window: %u", [aWindow window]);

    if (check)
    {
        cookie = xcb_change_window_attributes_checked(connection, [aWindow window], aMask, values);
    } else
    {
        cookie = xcb_change_window_attributes(connection, [aWindow window], aMask, values);
    }

    xcb_generic_error_t *error = xcb_request_check(connection, cookie);

    if (error != NULL)
        NSLog(@"Unable to change the attributes for window %u with error code: %d", [aWindow window],
              error->error_code);
    else
        attributesChanged = YES;

    free(error);

    return attributesChanged;
}

- (void)handleMapNotify:(xcb_map_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];
    NSLog(@"[%@] The window %u is mapped!", NSStringFromClass([self class]), [window window]);
    [window setIsMapped:YES];

    /*** use this for slower machines?**/

    /*if ([window pixmap] == 0 && [window isKindOfClass:[XCBWindow class]] &&
        [[window parentWindow] isKindOfClass:[XCBFrame class]] &&
        [window parentWindow] != [self rootWindowForScreenNumber:0])
        [NSThread detachNewThreadSelector:@selector(createPixmapDelayed) toTarget:window withObject:nil];*/

    window = nil;
}

- (void)handleUnMapNotify:(xcb_unmap_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];
    [window setIsMapped:NO];
    NSLog(@"[%@] The window %u is unmapped!", NSStringFromClass([self class]), [window window]);

    XCBFrame *frameWindow = (XCBFrame *) [window parentWindow];

    if (frameWindow && ![frameWindow isMinimized]) //FIXME: Check if the parent is a frame window before enter this 'if'
    {
        NSLog(@"Destroying window %u", [frameWindow window]);
        XCBRect rect = [window windowRect];
        [self reparentWindow:window toWindow:[self rootWindowForScreenNumber:0] position:rect.position];
        [window setDecorated:NO];
        [frameWindow destroy];
    }

    window = nil;
    frameWindow = nil;
    frameWindow = nil;
}

- (void)handleMapRequest:(xcb_map_request_event_t *)anEvent
{
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:self];
    BOOL isManaged = NO;
    XCBWindow *window = [self windowForXCBId:anEvent->window];

    NSLog(@"[%@] Map request for window %u", NSStringFromClass([self class]), anEvent->window);

    /** if already managed map it **/

    if (window != nil)
    {
        NSLog(@"Window %u already managed by the window manager.", [window window]);
        isManaged = YES;
        [self mapWindow:window];
        window = nil;
        ewmhService = nil;
        return;
    }

    /*** if already decorated and managed, map it. ***/

    if ([window decorated] && isManaged)
    {
        NSLog(@"Window with id %u already decorated", [window window]);

        [self mapWindow:window];
        window = nil;

        ewmhService = nil;
        return;
    }

    if ([window decorated] == NO && !isManaged)
    {
        window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window andConnection:self];
        [window updateAttributes];
        XCBAttributesReply *reply = [window attributes];

        if ([reply isError])
        {
            [reply description];
            reply = nil;
            return;
        }

        /** check the ovveride redirect flag, if yes the WM must not handle the window **/

        if (![reply isError])
        {
            if ([reply overrideRedirect] == YES)
            {
                NSLog(@"Override redirect detected"); //useless log
                window = nil;
                reply = nil;
                ewmhService = nil;
                return;
            }
            reply = nil;
        }

        /** check allowed actions **/
        [NSThread detachNewThreadSelector:@selector(checkNetWMAllowedActions) toTarget:window withObject:nil];

        /** check window type **/
        NSString *lel = [ewmhService EWMHWMWindowType];
        NSLog(@"XD %@ and window: %u", lel, [window window]);
        void *windowTypeReply = [ewmhService getProperty:[ewmhService EWMHWMWindowType]
                                            propertyType:XCB_ATOM_ATOM
                                               forWindow:window
                                                  delete:NO
                                                  length:UINT32_MAX];

        if (windowTypeReply)
        {
            xcb_atom_t *atom = (xcb_atom_t *) xcb_get_property_value(windowTypeReply);

            XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:self];
            NSString *name = [atomService atomNameFromAtom:*atom];
            NSLog(@"Name: %@", name);

            if (*atom == [[ewmhService atomService] atomFromCachedAtomsWithKey:[ewmhService EWMHWMWindowTypeDock]])
            {
                NSLog(@"Dock window %u to be registered", [window window]);
                [self registerWindow:window];
                [self mapWindow:window];
                [window setDecorated:NO];
                XCBWindow *parentWindow = [[XCBWindow alloc] initWithXCBWindow:anEvent->parent andConnection:self];
                [window setParentWindow:parentWindow];
                window = nil;
                ewmhService = nil;
                name = nil;
                parentWindow = nil;
                free(windowTypeReply);
                return;
            }

            if (*atom == [[ewmhService atomService] atomFromCachedAtomsWithKey:[ewmhService EWMHWMWindowTypeMenu]])
            {
                NSLog(@"Menu window %u to be registered", [window window]);
                [self registerWindow:window];
                [self mapWindow:window];
                [window setDecorated:NO];
                XCBWindow *parentWindow = [[XCBWindow alloc] initWithXCBWindow:anEvent->parent andConnection:self];
                [window setParentWindow:parentWindow];
                window = nil;
                ewmhService = nil;
                name = nil;
                parentWindow = nil;
                free(windowTypeReply);
                return;
            }

            if (*atom == [[ewmhService atomService] atomFromCachedAtomsWithKey:[ewmhService EWMHWMWindowTypeDialog]])
            {
                /*** FIXME: fix the position and the stack order of the dialog window ***/
                NSLog(@"Dialog window %u to be registered", [window window]);
                [self registerWindow:window];
                [self mapWindow:window];
                [window setDecorated:NO];
                XCBWindow *parentWindow = [[XCBWindow alloc] initWithXCBWindow:anEvent->parent andConnection:self];
                [window setParentWindow:parentWindow];
                NSLog(@"Parent from event: %u", [[window parentWindow] window]);
                window = nil;
                ewmhService = nil;
                name = nil;
                parentWindow = nil;
                free(windowTypeReply);
                return;
            }

            atom = NULL;
            name = nil;
        }

        /** check motif hints  **/

        void *motifHints = [ewmhService getProperty:[ewmhService MotifWMHints]
                                       propertyType:XCB_GET_PROPERTY_TYPE_ANY
                                          forWindow:window
                                             delete:NO
                                             length:5 * sizeof(uint64_t)];

        if (motifHints)
        {
            xcb_atom_t *atom = (xcb_atom_t *) xcb_get_property_value(motifHints);

            if (atom[0] == 3 && atom[1] == 0 && atom[2] == 0 && atom[3] == 0 && atom[4] == 0)
            {
                NSLog(@"Motif Icon: %d", [window window]);
                [window description];
                free(motifHints);
                xcb_get_property_reply_t  *reply = [ewmhService netWmIconFromWindow:window];
                CairoSurfacesSet *cairoSet = [[CairoSurfacesSet alloc] initWithConnection:self];
                [cairoSet buildSetFromReply:reply];
                [window setIcons:[cairoSet cairoSurfaces]];
                XCBGeometryReply *geometry = [window geometries];
                [window setWindowRect:[geometry rect]];
                [window setDecorated:NO];
                [window setScreen:[window onScreen]];
                [window updateAttributes];
                //[window drawIcons];
                [self mapWindow:window];
                [self registerWindow:window];
                window = nil;
                cairoSet = nil;
                ewmhService = nil;
                geometry = nil;
                free(reply);
                return;
            }

        }

        [window updateRectsFromGeometries];
        [self registerWindow:window];
        [window setFirstRun:YES];
        free(windowTypeReply);
    }

    [window setScreen:[window onScreen]];
    XCBScreen *screen =  [window screen]; //FIXME: [[window setScreen:[window onScreen]]; [window screen]?? So redundant!!!
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    uint32_t values[2] = {[screen screen]->white_pixel, FRAMEMASK};

    XCBCreateWindowTypeRequest *request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBFrameRequest];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setXPosition:[window windowRect].position.x];
    [request setYPosition:[window windowRect].position.y];
    [request setWidth:[window windowRect].size.width + 1];
    [request setHeight:[window windowRect].size.height + 22];
    [request setBorderWidth:3];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setVisual:visual];
    [request setValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK];
    [request setValueList:values];
    [request setClientWindow:window];

    XCBWindowTypeResponse *response = [self createWindowForRequest:request registerWindow:YES];

    XCBFrame *frame = [response frame];
    const xcb_atom_t atomProtocols[1] = {[[icccmService atomService] atomFromCachedAtomsWithKey:[icccmService WMDeleteWindow]]};

    [icccmService changePropertiesForWindow:frame
                                   withMode:XCB_PROP_MODE_REPLACE
                               withProperty:[icccmService WMProtocols]
                                   withType:XCB_ATOM_ATOM
                                 withFormat:32
                             withDataLength:1
                                   withData:atomProtocols];

    [ewmhService updateNetFrameExtentsForWindow:frame];
    [self mapWindow:frame];

    NSLog(@"Client window decorated with id %u", [window window]);
    [frame decorateClientWindow];
    [window updateAttributes];
    [frame setScreen:[window screen]];

    [self setNeedFlush:YES];
    window = nil;
    frame = nil;
    request = nil;
    response = nil;
    ewmhService = nil;
    screen = nil;
    visual = nil;
}

- (void)handleUnmapRequest:(xcb_unmap_window_request_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];
    NSLog(@"[%@] Unmap request for window %u", NSStringFromClass([self class]), [window window]);
    [self unmapWindow:window];
    [self setNeedFlush:YES];
    window = nil;
}

- (void)handleConfigureWindowRequest:(xcb_configure_request_event_t *)anEvent
{
    uint16_t config_win_mask = 0;
    uint32_t config_win_vals[7];
    unsigned short i = 0;
    XCBWindow *window = [self windowForXCBId:anEvent->window];

    /*** Handle configure requests (has it is) for windows we don't manage ***/

    if (window == nil || ![window decorated])
    {
        if (anEvent->value_mask & XCB_CONFIG_WINDOW_X)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_X;
            config_win_vals[i++] = anEvent->x;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_Y)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_Y;
            config_win_vals[i++] = anEvent->y;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_WIDTH)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_WIDTH;
            config_win_vals[i++] = anEvent->width;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_HEIGHT)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_HEIGHT;
            config_win_vals[i++] = anEvent->height;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_BORDER_WIDTH)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_BORDER_WIDTH;
            config_win_vals[i++] = anEvent->border_width;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_SIBLING)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_SIBLING;
            config_win_vals[i++] = anEvent->sibling;
        }

        if (anEvent->value_mask & XCB_CONFIG_WINDOW_STACK_MODE)
        {
            config_win_mask |= XCB_CONFIG_WINDOW_STACK_MODE;
            config_win_vals[i++] = anEvent->stack_mode;
        }

        xcb_configure_window(connection, anEvent->window, config_win_mask, config_win_vals);

        /*** necessary? ***/

        xcb_configure_notify_event_t event;

        event.event = anEvent->window;
        event.window = anEvent->window;
        event.x = anEvent->x;
        event.y = anEvent->y;
        event.border_width = anEvent->border_width;
        event.width = anEvent->width;
        event.height = anEvent->height;
        event.override_redirect = 0;
        event.above_sibling = anEvent->sibling;
        event.response_type = XCB_CONFIGURE_NOTIFY;
        event.sequence = 0;

        window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window andConnection:self];

        [self sendEvent:(const  char*) &event toClient:window propagate:NO];

    }
    else
    {
        [window configureForEvent:anEvent];
    }

    window = nil;
}

- (void)handleConfigureNotify:(xcb_configure_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];

    NSLog(@"In configure notify for window %u: %d, %d", anEvent->window, anEvent->x, anEvent->y);

    window = nil;

}

- (void)handleMotionNotify:(xcb_motion_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];
    XCBWindow *rootWindow = [self rootWindowForScreenNumber:0];

    if (dragState &&
        ([window window] != [rootWindow window]) &&
        ([[window parentWindow] window] != [rootWindow window]))
    {
        XCBFrame *frame = (XCBFrame *) [window parentWindow];
        [[frame childWindowForKey:(TitleBar)] grabPointer];

        NSPoint destPoint = NSMakePoint(anEvent->event_x, anEvent->event_y);
        [frame moveTo:destPoint];

        needFlush = YES;
        frame = nil;
    }

    if (resizeState)
    {
        //NSLog(@"Resizing");
        XCBFrame *frame;


        if ([window isKindOfClass:[XCBFrame class]])
            frame = (XCBFrame *) window;

        [frame resize:anEvent];

        frame = nil;
    }

    window = nil;
    rootWindow = nil;
}

- (void)handleButtonPress:(xcb_button_press_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];
    XCBFrame *frame;


    if ([window isCloseButton])
    {
        XCBFrame *frame = (XCBFrame *) [[window parentWindow] parentWindow];
        NSLog(@"Operations for frame window %u", [frame window]);

        BOOL check = [frame window] == [[[window parentWindow] parentWindow] window] ? YES : NO;
        currentTime = anEvent->time;

        XCBWindow *clientWindow = [frame childWindowForKey:ClientWindow];

        [self sendClientMessageTo:clientWindow message:WM_DELETE_WINDOW];

        if (frame != nil && check) //probably unnecessary check when fixed
        {
            /* i was using an artifact with [frame setNeedDestroy:YES]; to destroy the frame. All the time the client window is destroyed,
             an expose event is generated for the frame and close button, so i was calling [frame destroy]
             in handleExpose method (XCBConnection). I think that is totally wrong and bad */

            [frame setNeedDestroy:YES];
        }

        frame = nil;
        window = nil;
        clientWindow = nil;
        return;
    }

    if ([window isMinimizeButton])
    {
        frame = (XCBFrame*)[[window parentWindow] parentWindow];
        XCBWindow *clientWindow = [frame childWindowForKey:ClientWindow];
        [clientWindow cairoPreview];
        //[clientWindow createPixmap];
        [frame minimize];
        frame = nil;
        window = nil;
        return;
    }

    if ([window isMaximizeButton])
    {
        frame = (XCBFrame*)[[window parentWindow] parentWindow];
        XCBScreen *screen = [frame screen];
        [window maximizeToWidth:[screen width] andHeight:[screen height]];
        screen = nil;
        window = nil;
        frame = nil;
        return;
    }

    if ([window isMinimized])
    {
        [window restoreFromIconified];
        window = nil;
        return;
    }

    if ([window isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame *) window;
        XCBWindow *clientWindow = [frame childWindowForKey:ClientWindow];
        [clientWindow ungrabButton];

        clientWindow = nil;
    }

    if ([window isKindOfClass:[XCBTitleBar class]])
    {
        frame = (XCBFrame *) [window parentWindow];
        XCBWindow *clientWindow = [frame childWindowForKey:ClientWindow];
        [clientWindow ungrabButton];

        clientWindow = nil;
    }

    if ([window isKindOfClass:[XCBWindow class]] &&
        [[window parentWindow] isKindOfClass:[XCBFrame class]])
    {
        [window ungrabButton];
        [[window parentWindow] stackAbove]; //FIXME: not necessary
        frame = (XCBFrame *) [window parentWindow];
    }

    [frame stackAbove];
    XCBTitleBar *titleBar = (XCBTitleBar *) [frame childWindowForKey:TitleBar];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
    [self drawAllTitleBarsExcept:titleBar];

    [frame setOffset:XCBMakePoint(anEvent->event_x, anEvent->event_y)];

    if ([frame window] != anEvent->root && [[frame childWindowForKey:ClientWindow] canMove])
        dragState = YES;
    else
        dragState = NO;


    /*** RESIZE WINDOW BY CLICKING ON THE BORDER ***/

    if ([titleBar window] != anEvent->event && [[frame childWindowForKey:ClientWindow] canResize])
        [self borderClickedForFrameWindow:frame withEvent:anEvent];

    frame = nil;
    window = nil;
    titleBar = nil;
}

- (void)handleButtonRelease:(xcb_button_release_event_t *)anEvent
{
    dragState = NO;
    resizeState = NO;

    XCBWindow *window = [self windowForXCBId:anEvent->event];
    XCBFrame *frame;

    if ([window isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame *) window;
        [frame setBottomBorderClicked:NO];
        [frame setRightBorderClicked:NO];
        [frame setLeftBorderClicked:NO];
        [frame setTopBorderClicked:NO];

        /*if ([frame isAbove])
            [[frame childWindowForKey:ClientWindow] updatePixmap];*/

        frame = nil;
    }

    //TODO: FOR NOW JUST DISABLE THIS CODE AND DRAW EVER THE PIXMAP WHEN ICONIFY IN CAIRO DRAWER
    /*if ([window isKindOfClass:[XCBTitleBar class]])
    {
        XCBTitleBar* titleBar = (XCBTitleBar*)window;
        frame = (XCBFrame*)[titleBar parentWindow];

        if ([frame isAbove])
            [[frame childWindowForKey:ClientWindow] updatePixmap];

        frame = nil;
        titleBar = nil;
    }*/

    [window ungrabPointer];
    window = nil;
}

- (void)handleFocusOut:(xcb_focus_out_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];

    NSLog(@"Focus Out event for window: %u", anEvent->event);

    window = nil;
}

- (void)handleFocusIn:(xcb_focus_in_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];

    NSLog(@"Focus In event for window: %u", anEvent->event);

    window = nil;
}

- (void) handlePropertyNotify:(xcb_property_notify_event_t*)anEvent
{
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:self];
    NSString *testStr = @"_NET_ACTIVE_WINDOW";

    NSString *name = [atomService atomNameFromAtom:anEvent->atom];
    NSLog(@"Property changed for window: %u, with name: %@", anEvent->window, name);
    if ([name isEqualToString:testStr])
        NSLog(@"We got it!");

    return;
}

- (void)handleClientMessage:(xcb_client_message_event_t *)anEvent
{
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:self];
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:self];
    NSString *atomMessageName = [atomService atomNameFromAtom:anEvent->type];

    NSLog(@"Atom name: %@, for atom id: %u", atomMessageName, anEvent->type);

    XCBWindow *window;
    XCBTitleBar *titleBar;
    XCBFrame *frame;
    XCBWindow *clientWindow;

    XCBScreen *screen;
    XCBVisual *visual;

    CairoDrawer *drawer;
    window = [self windowForXCBId:anEvent->window];

    if (window == nil && frame == nil && titleBar == nil)
    {
        //NSLog(@"No existing window for id: %u", anEvent->window);

        if ([ewmhService ewmhClientMessage:atomMessageName])
        {
            window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window andConnection:self];
            //uint32_t values[] = {XCB_EVENT_MASK_PROPERTY_CHANGE};
            //[self changeAttributes:values forWindow:window withMask:XCB_CW_EVENT_MASK checked:NO];
            [ewmhService handleClientMessage:atomMessageName forWindow:window];
        }


        screen = nil;
        visual = nil;
        atomService = nil;
        ewmhService = nil;
        atomMessageName = nil;
        window = nil;
        return;
    }


    if ([window isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame *) [self windowForXCBId:anEvent->window];
        titleBar = (XCBTitleBar *) [frame childWindowForKey:TitleBar];
        clientWindow = [frame childWindowForKey:ClientWindow];
    }
    else if ([window isKindOfClass:[XCBTitleBar class]])
    {
        titleBar = (XCBTitleBar *) [self windowForXCBId:anEvent->window];
        frame = (XCBFrame *) [titleBar parentWindow];
        clientWindow = [frame childWindowForKey:ClientWindow];
    }
    else if ([window isKindOfClass:[XCBWindow class]])
    {
        window = [self windowForXCBId:anEvent->window];

        if ([window decorated])
        {
            frame = (XCBFrame *) [window parentWindow];
            titleBar = (XCBTitleBar *) [frame childWindowForKey:TitleBar];
            clientWindow = [frame childWindowForKey:ClientWindow];
        }
    }

    //xcb_atom_t changeStateAtom = [atomService atomFromCachedAtomsWithKey:@"WM_CHANGE_STATE"];

    if (anEvent->type == [atomService atomFromCachedAtomsWithKey:@"WM_CHANGE_STATE"] &&
        anEvent->format == 32 &&
        anEvent->data.data32[0] == ICCCM_WM_STATE_ICONIC)
    {

        if (frame != nil)
        {
            drawer = [[CairoDrawer alloc] initWithConnection:self window:clientWindow];
            [drawer makePreviewImage];
            XCBPoint position = XCBMakePoint(100, 100); //tmp position until i dont have a dock bar
            [frame createMiniWindowAtPosition:position];
            [frame setIsMinimized:YES];
        }

        if (titleBar != nil)
        {
            [self unmapWindow:titleBar];
        }

        if (clientWindow)
        {
            [clientWindow setIsMinimized:YES];
            [self unmapWindow:clientWindow];
            [frame updateAttributes];
            screen = [frame onScreen];
            [frame setScreen:screen];
            xcb_visualid_t visualid = [[frame attributes] visualId];
            visual = [[XCBVisual alloc] initWithVisualId:visualid
                                        withVisualType:xcb_aux_find_visual_by_id([screen screen], visualid)];
            [drawer setVisual:visual];
            [drawer setWindow:frame];
            [drawer setPreviewImage];
        }

    }

    window = nil;
    titleBar = nil;
    frame = nil;
    clientWindow = nil;
    drawer = nil;
    screen = nil;
    visual = nil;
    atomService = nil;
    atomMessageName = nil;

    return;
}

- (void)handleEnterNotify:(xcb_enter_notify_event_t *)anEvent
{
    NSLog(@"Enter notify for window: %u", anEvent->event);
    XCBWindow *window = [self windowForXCBId:anEvent->event];

    if ([window isKindOfClass:[XCBWindow class]] &&
        [[window parentWindow] isKindOfClass:[XCBFrame class]])
    {
        [window grabButton];
    }

    if ([window isKindOfClass:[XCBFrame class]])
    {
        XCBFrame *frameWindow = (XCBFrame *) window;
        XCBWindow *clientWindow = [frameWindow childWindowForKey:ClientWindow];

        [clientWindow grabButton];

        clientWindow = nil;
        frameWindow = nil;
    }

    if ([window isKindOfClass:[XCBTitleBar class]])
    {
        XCBTitleBar *titleBar = (XCBTitleBar *) window;
        XCBFrame *frameWindow = (XCBFrame *) [titleBar parentWindow];
        XCBWindow *clientWindow = [frameWindow childWindowForKey:ClientWindow];

        [clientWindow grabButton];

        titleBar = nil;
        frameWindow = nil;
        clientWindow = nil;
    }

    window = nil;
}

- (void)handleLeaveNotify:(xcb_leave_notify_event_t *)anEvent
{
    NSLog(@"Leave notify for window: %u", anEvent->event);
    XCBWindow *window = [self windowForXCBId:anEvent->event];

    if ([window isKindOfClass:[XCBWindow class]] &&
        [[window parentWindow] isKindOfClass:[XCBFrame class]])
    {
        [window ungrabButton];
    }

    if ([window isKindOfClass:[XCBFrame class]])
    {
        XCBFrame *frameWindow = (XCBFrame *) window;
        XCBWindow *clientWindow = [frameWindow childWindowForKey:ClientWindow];

        [clientWindow ungrabButton];

        frameWindow = nil;
        clientWindow = nil;
    }

    if ([window isKindOfClass:[XCBTitleBar class]])
    {
        XCBTitleBar *titleBar = (XCBTitleBar *) window;
        XCBFrame *frameWindow = (XCBFrame *) [titleBar parentWindow];
        XCBWindow *clientWindow = [frameWindow childWindowForKey:ClientWindow];

        [clientWindow ungrabButton];

        titleBar = nil;
        frameWindow = nil;
        clientWindow = nil;
    }

    window = nil;

}

- (void)handleVisibilityEvent:(xcb_visibility_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];
    XCBFrame *frame;
    XCBWindow *clientWindow;

    if ([window isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame *) window;
        clientWindow = [frame childWindowForKey:ClientWindow];
    }

    /*if (anEvent->state == XCB_VISIBILITY_UNOBSCURED &&
        anEvent->window == [frame window] &&
        [frame isAbove])
    {
        if ([clientWindow pixmap] == 0)
            [clientWindow createPixmap];
    }*/

    window = nil;
    clientWindow = nil;
}

- (void)handleExpose:(xcb_expose_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->window];
    [window setScreen:[window onScreen]];
    XCBVisual *visual = [window visual];

    if ([window isKindOfClass:[XCBTitleBar class]])
    {
        XCBTitleBar *titleBar = (XCBTitleBar *) window;
        XCBFrame *frame = (XCBFrame *) [titleBar parentWindow];
        [titleBar drawTitleBarComponentsForColor:[frame isAbove] ? TitleBarUpColor : TitleBarDownColor];

        titleBar = nil;
        frame = nil;
    }

    if ([window isKindOfClass:[XCBFrame class]])
    {
        XCBFrame *frame = (XCBFrame *) window;

        /*if ([frame isMinimized])
        {
            [frame createPixmap];

        }*/

        frame = nil;

    }

    window = nil;
    visual = nil;
}

- (void)handleReparentNotify:(xcb_reparent_notify_event_t *)anEvent
{
    NSLog(@"Yet Not Implemented");
}

- (void)handleDestroyNotify:(xcb_destroy_notify_event_t *)anEvent
{
    /* case to handle:
     * the window is a client window: get the frame
     * the window is a title bar child button window: get the frame from the title bar
     * after getting the frame:
     * unregister title bar, title bar children and client window.
     */

    XCBWindow *window = [self windowForXCBId:anEvent->window];
    XCBFrame *frameWindow = nil;
    XCBTitleBar *titleBarWindow = nil;
    XCBWindow *clientWindow = nil;

    if ([window isKindOfClass:[XCBFrame class]])
    {
        frameWindow = (XCBFrame *) window;
        titleBarWindow = (XCBTitleBar *) [frameWindow childWindowForKey:TitleBar];
        clientWindow = [frameWindow childWindowForKey:ClientWindow];
    }

    if ([window isKindOfClass:[XCBWindow class]])
    {
        if ([[window parentWindow] isKindOfClass:[XCBFrame class]]) /* then is the client window */
        {
            frameWindow = (XCBFrame *) [window parentWindow];
            clientWindow = window;
            titleBarWindow = (XCBTitleBar *) [frameWindow childWindowForKey:TitleBar];
            [frameWindow setNeedDestroy:YES]; /* at this point maybe i can avoid to force this to YES */
        }

        if ([[window parentWindow] isKindOfClass:[XCBTitleBar class]]) /* then is the client window */
        {
            frameWindow = (XCBFrame *) [[window parentWindow] parentWindow];
            [frameWindow setNeedDestroy:YES]; /* at this point maybe i can avoid to force this to YES */
            titleBarWindow = (XCBTitleBar *) [frameWindow childWindowForKey:TitleBar];
            clientWindow = [frameWindow childWindowForKey:ClientWindow];
        }

    }

    if ([window isKindOfClass:[XCBTitleBar class]])
    {
        titleBarWindow = (XCBTitleBar *) window;
        frameWindow = (XCBFrame *) [titleBarWindow parentWindow];
        clientWindow = [frameWindow childWindowForKey:ClientWindow];
    }

    if (frameWindow != nil &&
        [frameWindow needDestroy]) /*evaluete if the check on destroy window is necessary or not */
    {
        titleBarWindow = (XCBTitleBar *) [frameWindow childWindowForKey:TitleBar];
        [self unregisterWindow:[titleBarWindow hideWindowButton]];
        [self unregisterWindow:[titleBarWindow minimizeWindowButton]];
        [self unregisterWindow:[titleBarWindow maximizeWindowButton]];
        [self unregisterWindow:titleBarWindow];
        [self unregisterWindow:clientWindow];
        [[frameWindow getChildren] removeAllObjects];
        [frameWindow destroy];
    }

    [self unregisterWindow:window];


    frameWindow = nil;
    titleBarWindow = nil;
    window = nil;
    clientWindow = nil;

    return;
}

- (void)borderClickedForFrameWindow:(XCBFrame *)aFrame withEvent:(xcb_button_press_event_t *)anEvent
{
    int rightBorder = [aFrame windowRect].size.width;
    int bottomBorder = [aFrame windowRect].size.height;
    int leftBorder = [aFrame windowRect].position.x;
    int topBorder = [aFrame windowRect].position.y;

    if (rightBorder == anEvent->event_x || (rightBorder - 1) < anEvent->event_x)
    {
        if (![aFrame grabPointer])
        {
            NSLog(@"Unable to grab the pointer");
            return;
        }

        resizeState = YES;
        dragState = NO;
        [aFrame setRightBorderClicked:YES];
    }

    if (bottomBorder == anEvent->event_y || (bottomBorder - 1) < anEvent->event_y)
    {
        if (![aFrame grabPointer])
        {
            NSLog(@"Unable to grab the pointer");
            return;
        }

        resizeState = YES;
        dragState = NO;
        [aFrame setBottomBorderClicked:YES];

    }

    if ((bottomBorder == anEvent->event_y || (bottomBorder - 1) < anEvent->event_y) &&
        (rightBorder == anEvent->event_x || (rightBorder - 1) < anEvent->event_x))
    {
        if (![aFrame grabPointer])
        {
            NSLog(@"Unable to grab the pointer");
            return;
        }

        resizeState = YES;
        dragState = NO;
        [aFrame setBottomBorderClicked:YES];
        [aFrame setRightBorderClicked:YES];
    }

    if (leftBorder == anEvent->root_x || (leftBorder + 1) > anEvent->root_x)
    {
        if (![aFrame grabPointer])
        {
            NSLog(@"Unable to grab the pointer");
            return;
        }

        resizeState = YES;
        dragState = NO;

        [aFrame setLeftBorderClicked:YES];
    }

    if (topBorder == anEvent->root_y)
    {
        if (![aFrame grabPointer])
        {
            NSLog(@"Unable to grab the pointer");
            return;
        }

        resizeState = YES;
        dragState = NO;

        [aFrame setTopBorderClicked:YES];
    }

}

- (void)drawAllTitleBarsExcept:(XCBTitleBar *)aTitileBar
{

    NSArray *windows = [windowsMap allValues];
    NSUInteger size = [windows count];

    for (int i = 0; i < size; i++)
    {
        XCBWindow *tmp = [windows objectAtIndex:i];
        if ([tmp isKindOfClass:[XCBTitleBar class]])
        {
            XCBTitleBar *titleBar = (XCBTitleBar *) tmp;

            if (titleBar != aTitileBar)
            {
                XCBFrame *frame = (XCBFrame *) [titleBar parentWindow];
                [titleBar drawTitleBarComponentsForColor:TitleBarDownColor];
                [frame setIsAbove:NO];
                //[[frame childWindowForKey:ClientWindow] createPixmap];
                frame = nil;
            }

            titleBar = nil;
        }

        tmp = nil;
    }

    windows = nil;
}

- (void)sendClientMessageTo:(XCBWindow *)destination message:(Message)message
{
    xcb_client_message_event_t event;
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:self];

    switch (message)
    {
        case WM_DELETE_WINDOW:

            if ([icccmService hasProtocol:[icccmService WMDeleteWindow] forWindow:destination])
            {
                event.type = [atomService atomFromCachedAtomsWithKey:[icccmService WMProtocols]];
                event.format = 32;
                event.response_type = XCB_CLIENT_MESSAGE;
                event.window = [destination window];
                event.data.data32[0] = [atomService atomFromCachedAtomsWithKey:[icccmService WMDeleteWindow]];
                event.data.data32[1] = currentTime;
                event.data.data32[2] = 0;
                event.data.data32[3] = 0;
                event.sequence = 0;

                xcb_send_event(connection, false, [destination window], XCB_EVENT_MASK_NO_EVENT, (char *) &event);
            }
            /*else
             xcb_kill_client(connection, [destination window]);*/

            break;

        default:
            break;
    }

    atomService = nil;
}

- (void) sendEvent:(const char *)anEvent toClient:(XCBWindow*)aWindow propagate:(BOOL)propagating
{
    xcb_send_event(connection, propagating, [aWindow window], XCB_EVENT_MASK_STRUCTURE_NOTIFY, anEvent);
}

//TODO: tenere traccia del tempo per ogni evento.

- (xcb_timestamp_t)currentTime
{
    return currentTime;
}

- (void)setCurrentTime:(xcb_timestamp_t)time
{
    currentTime = time;
}

- (void)registerAsWindowManager:(BOOL)replace screenId:(uint32_t)screenId selectionWindow:(XCBWindow *)selectionWindow
{
    [selectionWindow setScreen:[selectionWindow onScreen]];
    XCBScreen *screen = [selectionWindow screen];
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:self];

    uint32_t values[1];
    values[0] = XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY;
    XCBWindow *rootWindow = [[XCBWindow alloc] initWithXCBWindow:[[screen rootWindow] window] andConnection:self];

    if (replace)
    {
        BOOL attributesChanged = [self changeAttributes:values forWindow:rootWindow withMask:XCB_CW_EVENT_MASK checked:YES];

        if (!attributesChanged)
        {
            NSLog(@"Can't register as window manager. Another one running? Use --replace");
            //NSLog(@"Trying co-runnig...");
            //values[0] = XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY;

            //attributesChanged = [self changeAttributes:values forWindow:rootWindow checked:YES];

            /*if (!attributesChanged)
             {
             NSLog(@"Can't co-running too");
             }*/
            rootWindow = nil;
            screen = nil;
            ewmhService = nil;
            return;
        }

        NSLog(@"Subtructure redirect was set to the root window");

        rootWindow = nil;
        screen = nil;
        ewmhService = nil;
        return;
    }

    NSLog(@"Replacing window manager");

    NSString *atomName = [NSString stringWithFormat:@"WM_S%d", screenId];

    [[ewmhService atomService] cacheAtom:atomName];

    xcb_atom_t internedAtom = [[ewmhService atomService] atomFromCachedAtomsWithKey:atomName];

    XCBSelection *selector = [[XCBSelection alloc] initWithConnection:self andAtom:internedAtom];

    BOOL aquired = [selector aquireWithWindow:selectionWindow replace:replace];

    if (aquired)
    {
        BOOL attributesChanged = [self changeAttributes:values forWindow:rootWindow withMask:XCB_CW_EVENT_MASK checked:YES];

        if (!attributesChanged)
        {
            NSLog(@"Can't register as window manager.");

            rootWindow = nil;
            screen = nil;
            selector = nil;
            atomName = nil;
            ewmhService = nil;
            return;
        }
    }

    NSLog(@"Registered as window manager");

    screen = nil;
    rootWindow = nil;
    selector = nil;
    atomName = nil;
    ewmhService = nil;
}

- (XCBWindow *)rootWindowForScreenNumber:(int)number
{
    return [[screens objectAtIndex:number] rootWindow];
}

- (void)addDamagedRegion:(XCBRegion *)damagedRegion
{
    if (damagedRegions == nil)
        damagedRegions = [[XCBRegion alloc] initWithConnection:self rectagles:0 count:0];

    [damagedRegions unionWithRegion:damagedRegion destination:damagedRegions];
    [self setNeedFlush:YES];
}

- (void)dealloc
{
    [screens removeAllObjects];
    screens = nil;
    [windowsMap removeAllObjects];
    windowsMap = nil;
    displayName = nil;
    damagedRegions = nil;
    xcb_disconnect(connection);
}


@end
