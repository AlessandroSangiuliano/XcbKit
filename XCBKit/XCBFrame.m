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
        [request setBorderWidth:1];
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
    
    // for now f it is nil just set an empty string
    
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
    
    if ([[rect size] getWidth] < anEvent->event_x && rightBorderClicked)
    {
        uint32_t values[] = {anEvent->event_x};
        xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_WIDTH, &values);
        xcb_configure_window([connection connection], [titleBar window], XCB_CONFIG_WINDOW_WIDTH, &values);
        xcb_configure_window([connection connection], [clientWindow window], XCB_CONFIG_WINDOW_WIDTH, &values);
        [[rect size] setWidth:anEvent->event_x];
        [[[titleBar windowRect] size] setWidth:anEvent->event_x];
        [[[clientWindow windowRect] size] setWidth:anEvent->event_x];
        [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
    }
    
    if ([[rect size] getHeight] < anEvent->event_y && bottomBorderClicked)
    {
        uint32_t values[] = {anEvent->event_y};
        xcb_configure_window([connection connection], window, XCB_CONFIG_WINDOW_HEIGHT, &values);
        xcb_configure_window([connection connection], [clientWindow window], XCB_CONFIG_WINDOW_HEIGHT, &values);
        [[rect size] setHeight:anEvent->event_y];
        [[[clientWindow windowRect] size] setHeight:anEvent->event_x];
    }
    
    rect = nil;
    clientWindow = nil;
    titleBar = nil;
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
