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
#import "XCBAtomService.h"
#import <Transformers.h>
#import "CairoDrawer.h"
#import "EWMHService.h"

@implementation XCBWindow

@synthesize graphicContextId;
@synthesize windowRect;
@synthesize decorated;
@synthesize draggable;
@synthesize isCloseButton;
@synthesize isMinimizeButton;
@synthesize isMaximizeButton;
@synthesize oldRect;
@synthesize isMaximized;
@synthesize isMinimized;
@synthesize connection;
@synthesize needDestroy;
@synthesize pixmap;

extern XCBConnection *XCBConn;

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
    draggable = YES;
    isCloseButton = NO;
    isMinimizeButton = NO;
    isMaximizeButton = NO;
    connection = aConnection;
    needDestroy = NO;
	   
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

- (void) createPixmap
{
    pixmap = xcb_generate_id([connection connection]);
    XCBScreen* screen = [[connection screens] objectAtIndex:0];
    xcb_create_pixmap([connection connection],
                      [screen screen]->root_depth,
                      pixmap,
                      window,
                      [[windowRect size] getWidth],
                      [[windowRect size] getHeight]);
    screen = nil;
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
    
    xcb_configure_window([XCBConn connection], window, tempMask, valueForBorder);
}

- (void) restoreDimensionAndPosition
{
    XCBFrame* frame = (XCBFrame*) [parentWindow parentWindow];
    XCBTitleBar* titleBar;
    
    if ([parentWindow isKindOfClass:[XCBTitleBar class]])
    {
        titleBar = FnFromXCBWindowToXCBTitleBar(parentWindow, XCBConn);
    }

    
    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    
    /*** restore to the previous dimension and position of the frame ***/
    
    [frame setWindowRect:[frame oldRect]];
    
    uint32_t valueList[4] =
    {
        [[[frame windowRect] position] getX],
        [[[frame windowRect] position] getY],
        [[[frame windowRect] size] getWidth],
        [[[frame windowRect] size] getHeight]
    };
    
    xcb_configure_window([XCBConn connection], [frame window], mask, &valueList);
    
    /*** restore the title bar pos and dim ***/
    
    [titleBar setWindowRect:[titleBar oldRect]];
    valueList[2] = [[[titleBar windowRect] size] getWidth];
    valueList[3] = [[[titleBar windowRect] size] getHeight];
    
    xcb_configure_window([XCBConn connection], [titleBar window], mask, &valueList);
    
    [titleBar drawTitleBar];
    [titleBar drawArcs];
    
    /*** restore dim and pos of the client window ***/
    
    XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];
    
    [clientWindow setWindowRect:[clientWindow oldRect]];
    valueList[0] = [[[clientWindow windowRect] position] getX];
    valueList[1] = [[[clientWindow windowRect] position] getY];
    valueList[2] = [[[clientWindow windowRect] size] getWidth];
    valueList[3] = [[[clientWindow windowRect] size] getHeight];
    
    xcb_configure_window([XCBConn connection], [clientWindow window], mask, &valueList);
    
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
    
    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;

    
    if ([parentWindow isKindOfClass:[XCBTitleBar class]])
    {
        titleBar = FnFromXCBWindowToXCBTitleBar(parentWindow, XCBConn);
    }
    
    if ([frame isMaximized])
    {
        [self restoreDimensionAndPosition];
        return;
    }
    
    /*** save previous dimensions and position of the window **/
    
    [frame setOldRect:[frame windowRect]];
    
    /*** redraw and resize the frame ***/
    
    uint32_t valueList[4] = {0, 0, width-2, height-2};
    
    xcb_configure_window([XCBConn connection], [frame window], mask, &valueList);
    
    /*** set the new position and window rect dimension for the frame ***/
    
    XCBSize* newSize = [[XCBSize alloc] initWithWidht:width-2 andHeight:height-2];
    XCBPoint* newPoint = [[XCBPoint alloc] initWithX:0 andY:0];
    XCBRect* newRect = [[XCBRect alloc] initWithPosition:newPoint andSize:newSize];
    [frame setWindowRect:newRect];
    
    newSize = nil;
    newPoint = nil;
    newRect = nil;
    
    /*** resize the title bar ***/
    
    [titleBar setOldRect:[titleBar windowRect]];
    
    uint16_t oldHeight = [[[titleBar windowRect] size] getHeight];
    
    newSize = [[XCBSize alloc] initWithWidht:width-2 andHeight:oldHeight];
    newPoint = [[XCBPoint alloc] initWithX:0 andY:0];
    newRect = [[XCBRect alloc] initWithPosition:newPoint andSize:newSize];
    
    valueList[3] = [[[titleBar windowRect] size] getHeight];
    
    xcb_configure_window([XCBConn connection], [titleBar window], mask, &valueList);
    
    /*** set the new title bar rect and redraw it ***/
    
    [titleBar setWindowRect:newRect];
    [titleBar drawTitleBar];
    [titleBar drawArcs];
    
    newSize = nil;
    newPoint = nil;
    newRect = nil;
    
    /*** resize the client window ***/
    
    XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];
    
    [clientWindow setOldRect:[clientWindow windowRect]];
    
    valueList[0] = 0;
    valueList[1] = 23;
    valueList[2] = width-2;
    valueList[3] = height-2;
    
    xcb_configure_window([XCBConn connection], [clientWindow window], mask, &valueList);
    
    /*** set the new position and dimensions of the client window ***/
    
    newSize = [[XCBSize alloc] initWithWidht:width-2 andHeight:height-2];
    newPoint = [[XCBPoint alloc] initWithX:0 andY:23];
    newRect = [[XCBRect alloc] initWithPosition:newPoint andSize:newSize];
    
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
    newRect = nil;
    newSize = nil;
    newPoint = nil;
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
}

- (void) createMiniWindowAtPosition:(XCBPoint*)position
{
    oldRect = windowRect;
    
    XCBSize* newSize =[[XCBSize alloc] initWithWidht:50 andHeight:50]; //misure di prova
    XCBRect* newRect = [[XCBRect alloc] initWithPosition:position andSize:newSize];
    
    windowRect = newRect;
    
    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    uint32_t valueList[4] = {[position getX], [position getY], [newSize getWidth], [newSize getHeight]};
    
    xcb_configure_window([connection connection], window, mask, &valueList);
    
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
    newSize = nil;
    newRect = nil;
    
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
    
    XCBPoint* position = [windowRect position];
    XCBSize* size =  [windowRect size];
    
    uint16_t mask = XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y | XCB_CONFIG_WINDOW_WIDTH | XCB_CONFIG_WINDOW_HEIGHT;
    uint32_t valueList[4] = {[position getX], [position getY], [size getWidth], [size getHeight]};
    
    xcb_configure_window([connection connection], window, mask, &valueList);
    
    // TODO: ripristinate eventual mask values
    
    if ([self isKindOfClass:[XCBFrame class]])
    {
        frame = (XCBFrame*)self;
        XCBTitleBar* titleBar = (XCBTitleBar*)[frame childWindowForKey:TitleBar];
        XCBWindow* clientWindow = [frame childWindowForKey:ClientWindow];
        
        [connection mapWindow:titleBar];
        [titleBar drawTitleBar];
        [titleBar drawArcs];
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
    
        
    [connection mapWindow:self];
    isMinimized = NO;
    
    [ewmhService changePropertiesForWindow:frame
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:@"WM_STATE"
                                  withType:XCB_ATOM_ATOM
                                withFormat:32
                            withDataLength:1
                                  withData:state];
    
    position = nil;
    size = nil;
    ewmhService = nil;
    atomService = nil;
}

- (void) destroy
{
    xcb_destroy_window([connection connection], window);
    [connection setNeedFlush:YES];
}

- (void) hide
{
    [connection unmapWindow:self];
    [connection setNeedFlush:YES];
}

- (void) description
{
    
    NSLog(@" Window id: %u. Parent window id: %u.\nWindow Size and Position:", window, [parentWindow window]);
    [[windowRect size] description];
    [[windowRect position] description];
}
	 
- (void) dealloc
{
	parentWindow = nil;
	aboveWindow = nil;
    windowRect = nil;
    oldRect = nil;
}

@end
