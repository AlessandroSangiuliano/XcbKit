//
//  XCBFrame.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 05/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBFrame.h"
#import "XCBVisual.h"
#import "functions/Transformers.h"
#import "XCBTitleBar.h"
#import "services/EWMHService.h"
#import "utils/XCBCreateWindowTypeRequest.h"
#import "utils/XCBWindowTypeResponse.h"
#import "services/ICCCMService.h"

@implementation XCBFrame

@synthesize minWidthHint;
@synthesize minHeightHint;
@synthesize connection;
@synthesize rightBorderClicked;
@synthesize bottomBorderClicked;
@synthesize offset;
@synthesize leftBorderClicked;
@synthesize topBorderClicked;

- (id) initWithClientWindow:(XCBWindow *)aClientWindow withConnection:(XCBConnection *)aConnection
{
    return [self initWithClientWindow:aClientWindow
                       withConnection:aConnection
                        withXcbWindow:0
                             withRect:XCBInvalidRect];
}

- (id) initWithClientWindow:(XCBWindow *)aClientWindow
             withConnection:(XCBConnection *)aConnection
              withXcbWindow:(xcb_window_t)xcbWindow
                   withRect:(XCBRect)aRect
{
    self = [super initWithXCBWindow: xcbWindow andConnection:aConnection];
    [self setWindowRect:aRect];
    [self setOriginalRect:aRect];
    /*** checks normal hints for client window **/
    
    ICCCMService* icccmService = [ICCCMService sharedInstanceWithConnection:connection];
    xcb_size_hints_t *sizeHints = [icccmService wmNormalHintsForWindow:aClientWindow];

    /**FIXME: this is not working; clang bug? note: assigning to int ivar is not working; assigning to local int var is warking. **/
   /* int minHAux = sizeHints->min_height;
    int minWAux = sizeHints->min_width;
    minHeightHint = minHAux;
    minWidthHint = minWAux;*/

   /**FIXME: above workaoround:**/
   minHeightHint = [NSNumber numberWithInt:sizeHints->min_height];
   minWidthHint = [NSNumber numberWithInt:sizeHints->min_width];
   NSLog(@"Gigio:%d", [minHeightHint intValue]);

    if ([minWidthHint intValue] > [aClientWindow windowRect].size.width)
    {
        XCBRect rect = XCBMakeRect(XCBMakePoint(0,0), XCBMakeSize([minWidthHint intValue], [aClientWindow windowRect].size.height));
        [aClientWindow setWindowRect:rect];
        [aClientWindow setOriginalRect:rect];
        rect.size.width = rect.size.width + 1;
        [self setWindowRect: rect];
        [self setOriginalRect:rect];
        uint32_t values[] = {rect.size.width};
        xcb_configure_window([aConnection connection], window, XCB_CONFIG_WINDOW_WIDTH, values);
        values[0] = [minWidthHint intValue];
        xcb_configure_window([aConnection connection], [aClientWindow window], XCB_CONFIG_WINDOW_WIDTH, values);
    }

    if ([minHeightHint intValue] > [aClientWindow windowRect].size.height)
    {
        XCBRect rect = XCBMakeRect(XCBMakePoint(0,0), XCBMakeSize([aClientWindow windowRect].size.width, [minHeightHint intValue]));
        [aClientWindow setWindowRect:rect];
        [aClientWindow setOriginalRect:rect];
        rect.size.height = rect.size.height + 21;
        [self setWindowRect:rect];
        [self setOriginalRect:rect];
        uint32_t values[] = {rect.size.height};
        xcb_configure_window([aConnection connection], window, XCB_CONFIG_WINDOW_HEIGHT, values);
        values[0] = [minHeightHint intValue];
        xcb_configure_window([aConnection connection], [aClientWindow window], XCB_CONFIG_WINDOW_HEIGHT, values);
    }

    [self description];
    connection = aConnection;
    children = [[NSMutableDictionary alloc] init];
    NSNumber *key = [NSNumber numberWithInteger:ClientWindow];
    [children setObject:aClientWindow forKey: key];
    [connection registerWindow:self];

    [super setIsAbove:YES];
    free(sizeHints);
    icccmService = nil;
    key= nil;
    return self;
}

- (void) addChildWindow:(XCBWindow *)aChild withKey:(childrenMask) keyMask
{
    NSNumber* key = [NSNumber numberWithInteger:keyMask];
    [children setObject:aChild forKey: key];
    key = nil;
}

- (XCBWindow*) childWindowForKey:(childrenMask)key
{
    NSNumber* keyNumber = [NSNumber numberWithInteger:key];
    XCBWindow* child = [children objectForKey:keyNumber];
    keyNumber = nil;
    return child;
}

-(void)removeChild:(childrenMask)frameChild
{
    NSNumber* key = [NSNumber numberWithInteger:frameChild];
    [children removeObjectForKey:key];
    key = nil;
}

- (void) decorateClientWindow
{
    NSNumber* key = [NSNumber numberWithInteger:ClientWindow];
    XCBWindow *clientWindow = [children objectForKey:key];
    key = nil;

    XCBTitleBar *titleBar = [[XCBTitleBar alloc] initWithFrame:self withConnection:connection];
    [self addChildWindow:titleBar withKey:TitleBar];

    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];

    void* reply = [ewmhService getProperty:[ewmhService EWMHWMName]
                              propertyType:XCB_GET_PROPERTY_TYPE_ANY
                                 forWindow:clientWindow
                                    delete:NO];

    NSString* windowTitle;
    if (reply)
    {
        char *value = xcb_get_property_value(reply);
        windowTitle = [NSString stringWithUTF8String:value];
        value = NULL;
    }

    // for now if it is nil just set an empty string

    if (windowTitle == nil)
    {
        ICCCMService* icccmService = [ICCCMService sharedInstanceWithConnection:connection];

        windowTitle = [icccmService getWmNameForWindow:clientWindow];

        if (windowTitle == nil)
            windowTitle = @"";

        icccmService = nil;
    }

    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
    [titleBar setWindowTitle:windowTitle];

    [connection mapWindow:titleBar];
    [titleBar setIsMapped:YES];
    [clientWindow setDecorated:YES];
    [clientWindow setWindowBorderWidth:0];

    XCBPoint position = XCBMakePoint(0, 21);
    [connection reparentWindow:clientWindow toWindow:self position:position];
    [connection mapWindow:clientWindow];

    titleBar = nil;
    clientWindow = nil;
    ewmhService = nil;
    windowTitle = nil;
    
    free(reply);
}

- (void) resize:(xcb_motion_notify_event_t *)anEvent
{
    /*** width ***/

    if (rightBorderClicked && !bottomBorderClicked && !leftBorderClicked && !topBorderClicked)
        resizeFromRightForEvent(anEvent, self, [minWidthHint intValue]);

    if (leftBorderClicked && !bottomBorderClicked && !rightBorderClicked && !topBorderClicked)
        resizeFromLeftForEvent(anEvent, self, [minWidthHint intValue]);



    /** height **/

    if (bottomBorderClicked && !rightBorderClicked && !leftBorderClicked)
        resizeFromBottomForEvent(anEvent, self, [minHeightHint intValue]);

    if (topBorderClicked && !rightBorderClicked && !leftBorderClicked && !bottomBorderClicked)
        resizeFromTopForEvent(anEvent, self, [minHeightHint intValue]);



    /** width and height **/

    if (rightBorderClicked && bottomBorderClicked && !leftBorderClicked)
    {
        resizeFromAngleForEvent(anEvent, self, [minWidthHint intValue], [minHeightHint intValue]);
    }

}

void resizeFromRightForEvent(xcb_motion_notify_event_t *anEvent, XCBFrame* window, int minW)
{
    XCBWindow* clientWindow = [window childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[window childWindowForKey:TitleBar];
    xcb_connection_t *connection = [[window connection] connection];

    XCBRect rect = [window windowRect];
    XCBRect titleBarRect = [titleBar windowRect];
    XCBRect clientRect = [clientWindow windowRect];

    uint32_t values[] = {anEvent->event_x};

    if (rect.size.width <= minW && anEvent->event_x < minW)
    {
        rect.size.width = minW;
        titleBarRect.size.width = minW;
        clientRect.size.width = minW;
        values[0] = minW;
        xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_WIDTH, &values);
        xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
        xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_WIDTH, &values);
        [window setWindowRect:rect];
        [window setOriginalRect:rect];

        [titleBar setWindowRect:titleBarRect];
        [titleBar setOriginalRect:titleBarRect];

        [clientWindow setWindowRect:clientRect];
        [clientWindow setOriginalRect:clientRect];
        [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

        clientWindow = nil;
        titleBar = nil;
        connection = NULL;
        return;
    }

    xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_WIDTH, &values);
    xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
    xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_WIDTH, &values);
    rect.size.width = anEvent->event_x;
    [window setWindowRect:rect];
    [window setOriginalRect:rect];

    titleBarRect.size.width = anEvent->event_x;
    [titleBar setWindowRect:titleBarRect];
    [titleBar setOriginalRect:titleBarRect];

    clientRect.size.width = anEvent->event_x;
    [clientWindow setWindowRect:clientRect];
    [clientWindow setOriginalRect:clientRect];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

    clientWindow = nil;
    titleBar = nil;
    connection = NULL;
}

void resizeFromLeftForEvent(xcb_motion_notify_event_t *anEvent, XCBFrame* window, int minW)
{
    XCBWindow* clientWindow = [window childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[window childWindowForKey:TitleBar];
    xcb_connection_t *connection = [[window connection] connection];

    XCBRect rect = [window windowRect];
    XCBRect titleBarRect = [titleBar windowRect];
    XCBRect clientRect = [clientWindow windowRect];

    int xDelta = rect.position.x - anEvent->root_x;
    uint32_t values[] = {anEvent->root_x, xDelta + rect.size.width};

    if (rect.size.width <= minW && anEvent->root_x > rect.position.x)
    {
        /* FIXME: when the reducing in a fast way, the resize works but there also is a little window movement, more noticeable
         * doing faster movements with the mouse while reducing */

        rect.size.width = minW;
        titleBarRect.size.width = minW;
        clientRect.size.width = minW;
        values[0] = rect.position.x;
        values[1] = minW;
        xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);
        values[0] = 0;
        xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);
        xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);

        [window setWindowRect:rect];
        [window setOriginalRect:rect];

        titleBarRect.position.x = values[0];
        titleBarRect.size.width = values[1];
        [titleBar setWindowRect:titleBarRect];
        [titleBar setOriginalRect:titleBarRect];

        clientRect.position.x = values[0];
        clientRect.size.width = values[1];
        [clientWindow setWindowRect:clientRect];
        [clientWindow setOriginalRect:clientRect];
        [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

        clientWindow = nil;
        titleBar = nil;
        connection = NULL;
        return;
    }


    xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);
    rect.position.x = values[0];
    rect.size.width = values[1];
    values[0] = 0;
    xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);
    xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_WIDTH, &values);

    [window setWindowRect:rect];
    [window setOriginalRect:rect];

    titleBarRect.position.x = values[0];
    titleBarRect.size.width = values[1];
    [titleBar setWindowRect:titleBarRect];
    [titleBar setOriginalRect:titleBarRect];

    clientRect.position.x = values[0];
    clientRect.size.width = values[1];
    [clientWindow setWindowRect:clientRect];
    [clientWindow setOriginalRect:clientRect];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

    clientWindow = nil;
    titleBar = nil;
    connection = NULL;

}

void resizeFromBottomForEvent(xcb_motion_notify_event_t *anEvent, XCBFrame* window, int minH)
{
    XCBWindow* clientWindow = [window childWindowForKey:ClientWindow];
    xcb_connection_t *connection = [[window connection] connection];

    XCBRect rect = [window windowRect];
    XCBRect clientRect = [clientWindow windowRect];

    uint32_t values[] = {anEvent->event_y};

    if (rect.size.height <= minH + 22 && anEvent->event_y < minH)
    {
        rect.size.height = minH + 22;
        clientRect.size.height = minH;
        values[0] = clientRect.size.height;
        xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_HEIGHT, &values);
        values[0] = rect.size.height;
        xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_HEIGHT, &values);

        [window setWindowRect:rect];
        [window setOriginalRect:rect];

        [clientWindow setWindowRect:clientRect];
        [clientWindow setOriginalRect:clientRect];

        clientWindow = nil;
        connection = NULL;
        return;
    }

    values[0] = anEvent->event_y - 22;
    xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_HEIGHT, &values);
    clientRect.size.height = values[0];
    values[0] = anEvent->event_y;
    xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_HEIGHT, &values);
    [clientWindow setWindowRect:clientRect];
    [clientWindow setOriginalRect:clientRect];


    rect.size.height = values[0];
    [window setWindowRect:rect];
    [window setOriginalRect:rect];

    clientWindow = nil;
    connection = NULL;
}

void resizeFromTopForEvent(xcb_motion_notify_event_t *anEvent, XCBFrame* window, int minH)
{
    XCBWindow* clientWindow = [window childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[window childWindowForKey:TitleBar];
    xcb_connection_t *connection = [[window connection] connection];

    XCBRect rect = [window windowRect];
    XCBRect titleBarRect = [titleBar windowRect];
    XCBRect clientRect = [clientWindow windowRect];

    int yDelta = rect.position.y - anEvent->root_y;
    uint32_t values[] = {anEvent->root_y, yDelta + rect.size.height};

    if (rect.size.height <= minH + 22 && anEvent->root_y > rect.position.y)
    {
        /* FIXME: when the reducing in a fast way, the resize works but there also is a little window movement, more noticeable
         * doing faster movements with the mouse while reducing */

        rect.size.height = minH + 22;
        clientRect.size.height = minH;
        values[0] = clientRect.position.y;
        values[1] = clientRect.size.height;
        xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_HEIGHT, &values);

        values[0] = rect.position.y;
        values[1] = rect.size.height;
        xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_HEIGHT, &values);


        [window setWindowRect:rect];
        [window setOriginalRect:rect];

        [clientWindow setWindowRect:clientRect];
        [clientWindow setOriginalRect:clientRect];

        titleBar = nil;
        clientWindow = nil;
        connection = NULL;

        return;
    }

    xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_HEIGHT, &values);

    rect.position.y = values[0];
    rect.size.height = values[1];
    values[0] = 0;

    xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_Y, &values);

    titleBarRect.position.y = values[0];

    values[0] = 22;
    values[1] = rect.size.height - 22;

    xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_HEIGHT, &values);
    clientRect.size.height = values[1];

    [window setWindowRect:rect];
    [window setOriginalRect:rect];

    [titleBar setWindowRect:titleBarRect];
    [titleBar setOriginalRect:titleBarRect];


    [clientWindow setWindowRect:clientRect];
    [clientWindow setOriginalRect:clientRect];

    clientWindow = nil;
    titleBar = nil;
    connection = NULL;
}

void resizeFromAngleForEvent(xcb_motion_notify_event_t *anEvent, XCBFrame *window, int minW, int minH)
{
    XCBWindow* clientWindow = [window childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[window childWindowForKey:TitleBar];
    xcb_connection_t *connection = [[window connection] connection];

    XCBRect rect = [window windowRect];
    XCBRect titleBarRect = [titleBar windowRect];
    XCBRect clientRect = [clientWindow windowRect];

    uint32_t values[] = {anEvent->event_x, anEvent->event_y};

    if (rect.size.width <= minW && anEvent->event_x < minW &&
        rect.size.height <= minH + 22 && anEvent->event_y < minH)
    {
        rect.size.width = minW;
        titleBarRect.size.width = minW;
        clientRect.size.width = minW;

        rect.size.height = minH + 22;
        clientRect.size.height = minH;

        values[0] = rect.size.width;
        values[1] = rect.size.height;

        xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT, &values);
        values[0] = titleBarRect.size.width;
        xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
        values[0] = clientRect.size.width;
        values[1] = clientRect.size.height;
        xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT, &values);

        [window setWindowRect:rect];
        [window setOriginalRect:rect];

        [titleBar setWindowRect:titleBarRect];
        [titleBar setOriginalRect:titleBarRect];

        [clientWindow setWindowRect:clientRect];
        [clientWindow setOriginalRect:clientRect];
        [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

        titleBar = nil;
        clientWindow = nil;
        connection = NULL;

        return;
    }

    xcb_configure_window(connection, [window window], XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT, &values);
    xcb_configure_window(connection, [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
    values[1] = values[1] - 22;
    xcb_configure_window(connection, [clientWindow window], XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT, &values);

    rect.size.width = anEvent->event_x;
    rect.size.height = anEvent->event_y;
    [window setWindowRect:rect];
    [window setOriginalRect:rect];


    titleBarRect.size.width = anEvent->event_x;
    [titleBar setWindowRect:titleBarRect];
    [titleBar setOriginalRect:titleBarRect];

    clientRect.size.width = anEvent->event_x;
    clientRect.size.height = values[1];
    [clientWindow setWindowRect:clientRect];
    [clientWindow setOriginalRect:clientRect];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

    titleBar = nil;
    clientWindow = nil;
    connection = NULL;
}

- (void) moveTo:(NSPoint)coordinates
{
    XCBPoint pos = [super windowRect].position;

    int16_t x =  pos.x;
    int16_t y =  pos.y;

    x = x + coordinates.x - offset.x;
    y = y + coordinates.y - offset.y;

    pos.x = x;
    pos.y = y;

    XCBRect newRect = XCBMakeRect(pos, XCBMakeSize([super windowRect].size.width, [super windowRect].size.height));
    [super setWindowRect:newRect];

    [super setOriginalRect:XCBMakeRect(XCBMakePoint(x, y),
                                       XCBMakeSize([super originalRect].size.width,
                                                   [super originalRect].size.height))];

    int32_t values[] = {pos.x, pos.y};

    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y, values);
}


/********************************
 *                               *
 *            ACCESSORS          *
 *                               *
 ********************************/

- (void)setChildren:(NSMutableDictionary *)aChildrenSet
{
    children = aChildrenSet;
}

-(NSMutableDictionary*) getChildren
{
    return children;
}

- (void) dealloc
{
    [children removeAllObjects];
    children = nil;
    minWidthHint = nil;
    minHeightHint = nil;
}


@end
