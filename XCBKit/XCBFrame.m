//
//  XCBFrame.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 05/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBFrame.h"
#import "XCBVisual.h"
#import "Transformers.h"
#import "XCBTitleBar.h"
#import "EWMHService.h"
#import "XCBCreateWindowTypeRequest.h"
#import "XCBWindowTypeResponse.h"
#import "ICCCMService.h"


@implementation XCBFrame

@synthesize connection;
@synthesize rightBorderClicked;
@synthesize bottomBorderClicked;

/* 
 quando il wm intercetta la finestra dell'app client inizializza il frame, poi si occupa di ridimensionare il frame per inserire
 la title bar window, i bordi e riparentare tutto 
 */

- (id) initWithClientWindow:(XCBWindow *)aClientWindow withConnection:(XCBConnection *)aConnection
{
    return [self initWithClientWindow:aClientWindow withConnection:aConnection withXcbWindow:0];
}

- (id) initWithClientWindow:(XCBWindow *)aClientWindow withConnection:(XCBConnection *)aConnection withXcbWindow:(xcb_window_t)xcbWindow
{
    self = [super initWithXCBWindow: xcbWindow andConnection:aConnection];
    [self setWindowRect:[aClientWindow windowRect]];
    [self setOriginalRect:[aClientWindow windowRect]];
    
    uint16_t width =  [[[aClientWindow windowRect] size] getWidth] + 1;
    uint16_t height =  [[[aClientWindow windowRect] size] getHeight] + 22;
    
    connection = aConnection;
    XCBScreen *screen = [[connection screens] objectAtIndex:0];

    uint32_t values[2] = {[screen screen]->white_pixel, XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS |
        XCB_EVENT_MASK_STRUCTURE_NOTIFY | XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_KEY_PRESS |
        XCB_EVENT_MASK_BUTTON_MOTION | XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT | XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY |
        XCB_EVENT_MASK_FOCUS_CHANGE | XCB_EVENT_MASK_ENTER_WINDOW | XCB_EVENT_MASK_LEAVE_WINDOW};
    
    
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    XCBWindowTypeResponse* response;
    
    if (xcbWindow == 0)
    {
        XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBFrameRequest];
        [request setDepth:[screen screen]->root_depth];
        [request setParentWindow:[screen rootWindow]];
        [request setXPosition:[[[aClientWindow windowRect] position] getX]];
        [request setXPosition:[[[aClientWindow windowRect] position] getY]];
        [request setWidth:width];
        [request setHeight:height];
        [request setBorderWidth:3];
        [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
        [request setVisual:visual];
        [request setValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK];
        [request setValueList:values];
        
        response = [connection createWindowForRequest:request registerWindow:NO];
        
        CsMapXCBWindoToXCBFrame([response frame], self);
        
        children = [[NSMutableDictionary alloc] init];
        [children setObject:aClientWindow forKey: [NSNumber numberWithInteger:ClientWindow]];
        [connection registerWindow:self];
        
        response = nil;
        request = nil;
    }
    
    
    [connection mapWindow:self];
    return self;
}

- (void) addChildWindow:(XCBWindow *)aChild withKey:(childrenMask) keyMask
{
    [children setObject:aChild forKey: [NSNumber numberWithInteger:keyMask]];
}

- (XCBWindow*) childWindowForKey:(childrenMask)key
{
    return [children objectForKey:[NSNumber numberWithInteger:key]];
}

-(void)removeChild:(childrenMask)frameChild
{
    [children removeObjectForKey:[NSNumber numberWithInteger:frameChild]];
}

- (void) decorateClientWindow
{
    XCBWindow *clientWindow = [children objectForKey:[NSNumber numberWithInteger:ClientWindow]];
    
    XCBTitleBar *titleBar = [[XCBTitleBar alloc] initWithFrame:self withConnection:connection];
    [self addChildWindow:titleBar withKey:TitleBar];
    
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    char* value = [ewmhService getProperty:[ewmhService EWMHWMName]
                              propertyType:[[ewmhService atomService] atomFromCachedAtomsWithKey:[ewmhService UTF8_STRING]]
                                 forWindow:clientWindow
                                    delete:NO];
    
    NSString *windowTitle = [NSString stringWithUTF8String:value];
    value = nil;
    
    // for now if it is nil just set an empty string
    
    if (windowTitle == nil)
    {
        ICCCMService* icccmService = [ICCCMService sharedInstanceWithConnection:connection];
        value = [icccmService getProperty:[icccmService WMName]
                              propertyType:XCB_ATOM_STRING
                                forWindow:clientWindow
                                   delete:NO];
        
        windowTitle = [NSString stringWithUTF8String:value];
        
        if (windowTitle == nil)
            windowTitle = @"";
        
        icccmService = nil;
        value = nil;
    }
    
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
    [titleBar setWindowTitle:windowTitle];
    
    [connection mapWindow:titleBar];
    [titleBar setIsMapped:YES];
    [clientWindow setDecorated:YES];
    [clientWindow setWindowBorderWidth:0];
    
    XCBPoint *position = [[XCBPoint alloc] initWithX:0 andY:21];
    [connection reparentWindow:clientWindow toWindow:self position:position];
    [connection mapWindow:clientWindow];
    
    position = nil;
    titleBar = nil;
    clientWindow = nil;
    ewmhService = nil;
    windowTitle = nil;
}

- (void) resize:(xcb_motion_notify_event_t *)anEvent
{
    /*** width ***/
    
    XCBRect* rect = [super windowRect];
    XCBWindow* clientWindow = [self childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[self childWindowForKey:TitleBar];
    
    if (rightBorderClicked && !bottomBorderClicked)
        [self resizeFromRightForEvent:anEvent];
    
    
    /** height **/
    
    if (bottomBorderClicked && !rightBorderClicked)
        [self resizeFromBottomForEvent:anEvent];
    
    /** width and height **/
    
    if (rightBorderClicked && bottomBorderClicked)
    {
        [self resizeFromBottomForEvent:anEvent];
        [self resizeFromRightForEvent:anEvent];
    }
    
    
    
    rect = nil;
    clientWindow = nil;
    titleBar = nil;
}

- (void) resizeFromRightForEvent:(xcb_motion_notify_event_t *)anEvent
{
    XCBRect* rect = [super windowRect];
    XCBWindow* clientWindow = [self childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[self childWindowForKey:TitleBar];
    
    uint32_t values[] = {anEvent->event_x};
    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_WIDTH, &values);
    xcb_configure_window([connection connection], [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
    xcb_configure_window([connection connection], [clientWindow window], XCB_CONFIG_WINDOW_WIDTH, &values);
    [[rect size] setWidth:anEvent->event_x];
    [[[titleBar windowRect] size] setWidth:anEvent->event_x];
    [[[clientWindow windowRect] size] setWidth:anEvent->event_x];
    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
    
    rect = nil;
    clientWindow = nil;
    titleBar = nil;
}

- (void) resizeFromBottomForEvent:(xcb_motion_notify_event_t *)anEvent
{
    XCBRect* rect = [super windowRect];
    XCBWindow* clientWindow = [self childWindowForKey:ClientWindow];
    XCBTitleBar* titleBar = (XCBTitleBar*)[self childWindowForKey:TitleBar];
    
    uint32_t values[] = {anEvent->event_y};
    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_HEIGHT, &values);
    [[rect size] setHeight:anEvent->event_y];
    NSLog(@"Frame:");
    [self description];
    
    values[0] = anEvent->event_y - 22;
    xcb_configure_window([connection connection], [clientWindow window], XCB_CONFIG_WINDOW_HEIGHT, &values);
    [[[clientWindow windowRect] size] setHeight:values[0]];
    NSLog(@"Client:");
    [clientWindow  description];

    rect = nil;
    clientWindow = nil;
    titleBar = nil;
}

- (void) moveTo:(NSPoint)coordinates
{
    XCBPoint *pos = [[super windowRect] position]; //TODO: qundo faccio il restore da icone questo è nil. fixare
    XCBPoint *offset = [[super windowRect] offset];
    
    if (pos == NULL)
        return;
    
    int16_t x =  [pos getX];
    int16_t y = [pos getY];
    
    x = x + coordinates.x - [offset getX];
    y = y + coordinates.y - [offset getY];
    
    [pos setX:x];
    [pos setY:y];
    [[[super originalRect] position] setX:x];
    [[[super originalRect] position] setY:y];
    
    xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y, [pos values]);
    
    pos = nil;
    offset = nil;
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
}


@end
