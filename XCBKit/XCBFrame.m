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

@implementation XCBFrame

@synthesize connection;

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
    self = [super initWithXCBWindow: xcbWindow];
    children = [[NSMutableDictionary alloc] init];
    [children setObject:aClientWindow forKey: [NSNumber numberWithInteger:ClientWindow]];
    connection = aConnection;
    [self setWindowRect:[aClientWindow windowRect]];
    
    uint16_t width =  [[[aClientWindow windowRect] size] getWidth] + 1;
    uint16_t height =  [[[aClientWindow windowRect] size] getHeight] + 22;
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    
    uint32_t values[2] = {[screen screen]->white_pixel, XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_STRUCTURE_NOTIFY
        | XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_KEY_PRESS | XCB_EVENT_MASK_BUTTON_MOTION};
    
    
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    XCBWindow *frameWindow;
    
    if (xcbWindow == 0)
    {
        frameWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                                  withParentWindow:[screen rootWindow]
                                                     withXPosition:[[[aClientWindow windowRect] position] getX]
                                                     withYPosition:[[[aClientWindow windowRect] position] getY]
                                                         withWidth:width
                                                        withHeight:height
                                                  withBorrderWidth:1
                                                      withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                      withVisualId:visual
                                                     withValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK
                                                     withValueList:values];
        
        CsMapXCBWindoToXCBFrame(frameWindow, self);
    }
    
    [connection mapWindow:self];
    frameWindow = nil;
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
    
    /*uint16_t width =  [[[clientWindow windowRect] size] getWidth] + 1;
    uint16_t height =  [[[clientWindow windowRect] size] getHeight] + 22;
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    
    uint32_t values[2] = {[screen screen]->white_pixel, XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_STRUCTURE_NOTIFY
        | XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_KEY_PRESS | XCB_EVENT_MASK_BUTTON_MOTION};
    
    
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    
    XCBWindow *frameWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                              withParentWindow:[screen rootWindow]
                                                 withXPosition:[[[clientWindow windowRect] position] getX]
                                                 withYPosition:[[[clientWindow windowRect] position] getY]
                                                     withWidth:width
                                                    withHeight:height
                                              withBorrderWidth:1
                                                  withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                  withVisualId:visual
                                                 withValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK
                                                 withValueList:values];
    
    //Map the frameWindow to this frame.
    
    CsMapXCBWindoToXCBFrame(frameWindow, self);*/
    //[connection mapWindow:self];
    
    //frameWindow = nil;
    
    XCBTitleBar *titleBar = [[XCBTitleBar alloc] initWithFrame:self withConnection:connection];
    [self addChildWindow:titleBar withKey:TitleBar];
    
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    const char* value = [ewmhService getProperty:[ewmhService EWMHWMName] forWindow:clientWindow delete:NO];
    NSString *windowTitle = [NSString stringWithUTF8String:(const char *)value];
    
    // for now f it is nil just set an empty string
    
    if (windowTitle == nil)
        windowTitle = @"";
    
    [titleBar drawTitleBar];
    [titleBar drawArcs];
    [titleBar setWindowTitle:windowTitle];
    
    [connection mapWindow:titleBar];
    [titleBar setIsMapped:YES];
    [clientWindow setDecorated:YES];
    
    /*uint16_t mask = XCB_CONFIG_WINDOW_BORDER_WIDTH;
    uint32_t valueForBorder[1] = {0};
    
    xcb_configure_window([connection connection], [clientWindow window], mask, valueForBorder);*/
    
    [clientWindow setWindowBorderWidth:0];
    
    XCBPoint *position = [[XCBPoint alloc] initWithX:0 andY:21];
    [connection reparentWindow:clientWindow toWindow:self position:position];
    [connection mapWindow:clientWindow];
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
