//
//  XCBConnection.m
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBConnection.h"
#import "EWMHService.h"
#import "XCBFrame.h"
#import "XCBSelection.h"
#import "XCBTitleBar.h"

EWMHService *ewmhService;

@implementation XCBConnection

@synthesize dragState;

XCBConnection *XCBConn;

- (id) init
{
	return [self initWithDisplay:NULL];
}

- (id) initWithDisplay:(NSString *)aDisplay
{
    self = [super init];
	const char *localDisplayName = NULL;
	needFlush = NO;
    dragState = NO;
	
	if (aDisplay == NULL)
	{
		NSLog(@"[XCBConnection] Connecting to the default display in env DISPLAY");
	}
	else
	{
		NSLog(@"XCBConnection: Creating connection with display: %@", aDisplay);
		localDisplayName = [aDisplay UTF8String];
	}
    
    windowsMap = [[NSMutableDictionary alloc] initWithCapacity:1000];
	
	screens = [NSMutableArray new];

    [NSRunLoop currentRunLoop];

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
	
	xcb_screen_iterator_t iterator = xcb_setup_roots_iterator(xcb_get_setup(connection));
	
	while (iterator.rem)
	{
		xcb_screen_t *scr = iterator.data;
		[screens addObject:[XCBScreen screenWithXCBScreen:scr]];
		
		NSLog(@"[XCBConnection] Screen with root window: %d;\n\
			  With width in pixels: %d;\n\
			  With height in pixels: %d\n",
			  scr->root,
			  scr->width_in_pixels,
			  scr->height_in_pixels);
		
		[self registerWindow: [[XCBWindow alloc] initWithXCBWindow:scr->root withParentWindow:XCB_NONE]];
        // tutto sbagliato da qui in poi
        /*uint32_t values[1];
        values[0] = XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT;
        
        XCBWindow* rootWindow = [[XCBWindow alloc] initWithXCBWindow:scr->root];
        BOOL attributesChanged = [self changeAttributes:values forWindow: rootWindow checked:YES];
        
        if (!attributesChanged)
        {
            NSLog(@"Can't register as window manager. Another one running?");
            NSLog(@"Trying co-runnig...");
            values[0] = XCB_EVENT_MASK_SUBSTRUCTURE_NOTIFY;
            
            attributesChanged = [self changeAttributes:values forWindow:rootWindow checked:YES];
            
            if (!attributesChanged)
            {
                NSLog(@"Can't co-running too");
            }
        }*/

		xcb_screen_next(&iterator);
	}
    
    ewmhService = [EWMHService sharedInstanceWithConnection:self];
    currentTime = XCB_CURRENT_TIME;
	
    XCBConn = self;
    [self flush];
    return self;
}

+ (XCBConnection*)sharedConnection
{
	if (XCBConn == nil)
	{
		NSLog(@"[XCBConnection]: Creating shared connection...");
        [[self alloc] init];
	}
    
	return XCBConn;
}

- (xcb_connection_t *) connection
{
    return connection;
}

- (NSMutableDictionary *) windowsMap
{
	return windowsMap;
}

- (void) registerWindow:(XCBWindow *)aWindow
{
	NSLog(@"[XCBConnection] Adding the window %u in the windowsMap", [aWindow window]);
    NSNumber *key = [[NSNumber alloc] initWithInt:[aWindow window]];
    //xcb_window_t window = [[windowsMap objectForKey:key] unsignedIntValue];
    XCBWindow* window = [windowsMap objectForKey:key];
    
    if (window != nil)
    {
        NSLog(@"Window %u previously added", [window window]);
        return;
    }
    
    [windowsMap setObject:aWindow forKey:key];
}

- (void) unregisterWindow:(XCBWindow *)aWindow
{
	NSLog(@"[XCBConnection] Removing the window %u from the windowsMap", [aWindow window]);
    [windowsMap removeObjectForKey:[[NSNumber alloc] initWithInt:[aWindow window]]];
}

- (void) closeConnection
{
	xcb_disconnect(connection);
}

- (XCBWindow *) windowForXCBId:(xcb_window_t)anId
{
    NSNumber *key = [NSNumber numberWithInt:anId];
	return [windowsMap objectForKey:key];
}

- (int) flush
{
	int flushResult = xcb_flush(connection);
	needFlush = NO;
	return flushResult;
}

- (void) setNeedFlush:(BOOL) aNeedFlushChoice
{
	needFlush = aNeedFlushChoice;
}

- (NSMutableArray*) screens
{
	return screens;
}

- (XCBWindow *) createWindowWithDepth: (uint8_t) depth // clonare questo metodo per la xcb_drawable_t
			  withParentWindow: (XCBWindow *) aParentWindow
				 withXPosition: (int16_t) xPosition
				 withYPosition: (int16_t) yPosition
					 withWidth: (int16_t) width
					withHeight: (int16_t) height
			  withBorrderWidth: (uint16_t) borderWidth
				  withXCBClass: (uint16_t) xcbClass
				  withVisualId: (XCBVisual*) aVisual
				 withValueMask: (uint32_t) valueMask
				 withValueList: (const uint32_t *) valueList
{
	xcb_window_t winId = xcb_generate_id(connection);
	XCBWindow *winToCreate = [[XCBWindow alloc] initWithXCBWindow:winId withParentWindow:aParentWindow];
    
    XCBPoint *coordinates = [[XCBPoint alloc] initWithX:xPosition andY:yPosition];
    XCBSize *windowSize = [[XCBSize alloc] initWithWidht:width andHeight:height];
    XCBRect *windowRect = [[XCBRect alloc] initWithPosition:coordinates andSize:windowSize];
    [winToCreate setWindowRect:windowRect];
    
	xcb_create_window(connection,
					  depth,
					  winId,
					  [aParentWindow window],
					  [[[winToCreate windowRect] position] getX],
					  [[[winToCreate windowRect] position] getY],
					  [[[winToCreate windowRect] size] getWidth],
					  [[[winToCreate windowRect] size] getHeight],
					  borderWidth,
					  xcbClass,
					  [aVisual visualId],
					  valueMask,
					  valueList);
    
	
    needFlush = YES;
    [self registerWindow:winToCreate];
	return winToCreate;

}

- (void) mapWindow:(XCBWindow *)aWindow
{
    xcb_map_window(connection, [aWindow window]);
    [aWindow setIsMapped:YES];
}

- (void) reparentWindow:(XCBWindow *)aWindow toWindow:(XCBWindow *)parentWindow position:(XCBPoint*)position
{
    xcb_reparent_window(connection, [aWindow window], [parentWindow window], [position getX], [position getY]);
    [aWindow setParentWindow:parentWindow];
}

- (XCBWindow*) parentWindowForWindow:(XCBWindow *)aWindow
{
    xcb_query_tree_cookie_t cookie = xcb_query_tree(connection, [aWindow window]);
    
    xcb_generic_error_t *error;
    
    xcb_query_tree_reply_t *reply = xcb_query_tree_reply(connection, cookie, &error);
    
    XCBWindow *parent = [[XCBWindow alloc] initWithXCBWindow:reply->parent];
    
    XCBRect *windowRect = [self geometryForWindow:parent];
    [parent setWindowRect:windowRect];
    
    windowRect = nil;
    
    return parent;
}

- (XCBRect*) geometryForWindow:(XCBWindow *)aWindow
{
    xcb_get_geometry_cookie_t cookie = xcb_get_geometry(connection, [aWindow window]);
    xcb_generic_error_t *error;
    xcb_get_geometry_reply_t *reply =  xcb_get_geometry_reply(connection, cookie, &error);
    
    if (reply == NULL)
    {
        return nil;
    }
    
    XCBPoint *position = [[XCBPoint alloc] initWithX:reply->x andY:reply->y];
    XCBSize *size = [[XCBSize alloc] initWithWidht:reply->width andHeight:reply->height];
    
    XCBRect * rect = [[XCBRect alloc] initWithPosition:position andSize:size];
    
    position = nil;
    size = nil;
    
    return rect;
}

- (BOOL) changeAttributes:(uint32_t[])values forWindow:(XCBWindow *)aWindow checked:(BOOL)check
{
    uint32_t mask = XCB_CW_EVENT_MASK;
    xcb_void_cookie_t cookie;
    
    BOOL attributesChanged = NO;
    
    NSLog(@"Changing attributes for window: %u", [aWindow window]);
    
    if (check)
    {
        cookie = xcb_change_window_attributes_checked(connection, [aWindow window], mask, values);
    }
    else
    {
        cookie = xcb_change_window_attributes(connection, [aWindow window], mask, values);
    }
        
    xcb_generic_error_t *error = xcb_request_check(connection, cookie);
    
    if (error != NULL)
    {
        NSLog(@"Unable to change the attributes for window %u with error code: %d", [aWindow window], error->error_code);
    }
    else
        attributesChanged = YES;
    
    return attributesChanged;
}

- (xcb_get_window_attributes_reply_t*) getAttributesForWindow:(XCBWindow *)aWindow
{
    xcb_get_window_attributes_cookie_t cookie = xcb_get_window_attributes(connection, [aWindow window]);
    xcb_get_window_attributes_reply_t *reply = xcb_get_window_attributes_reply(connection, cookie, NULL);
    
    return reply;
}

- (void)handleMapNotify: (xcb_map_notify_event_t*) anEvent
{
	XCBWindow *window  = [self windowForXCBId: anEvent->window];
	xcb_get_window_attributes_reply_t attributes;
	attributes.map_state = XCB_MAP_STATE_VIEWABLE;
	attributes.response_type = anEvent->response_type;
	[window setAttributes:attributes];
	
	NSLog(@"[%@] The window %u is mapped!", NSStringFromClass([self class]), [window window]);
	[window setIsMapped:YES];
}

- (void) handleUnMapNotify:(xcb_map_notify_event_t *) anEvent
{
	XCBWindow *window = [self windowForXCBId:anEvent->window];
	xcb_get_window_attributes_reply_t attributes;
	attributes.map_state = XCB_MAP_STATE_UNMAPPED;
	[window setIsMapped:NO];
	NSLog(@"[%@] The window %u is unmapped!", NSStringFromClass([self class]), [window window]);
}

- (void)handleMapRequest: (xcb_map_request_event_t*)anEvent
{
    BOOL isManaged = NO;
	XCBWindow *window = [self windowForXCBId:anEvent->window];
	NSLog(@"[%@] Map request for window %u", NSStringFromClass([self class]), [window window]);
	/*xcb_map_window(connection, [window window]);
	[window setIsMapped:YES];*/
    
    if (window != nil)
    {
        NSLog(@"Window %u already managed by the window manager.", [window window]);
        isManaged = YES;
    }
    
    // if already decorated for now just return, in future avoid to decorate but DO the other requests like redraw.
    if ([window decorated] && isManaged)
    {
        NSLog(@"Window with id %u already decorated", [window window]);
        return;
    }

    if ([window decorated] == NO && !isManaged)
    {
        window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window];
        XCBRect *rect = [self geometryForWindow:window];
        [window setWindowRect:rect];
        [self registerWindow:window];
    }

    XCBFrame *frame = [[XCBFrame alloc] initWithClientWindow:window withConnection:self];
    [frame decorateClientWindow];
    
	[self setNeedFlush:YES];
}

- (void) handleUnmapRequest:(xcb_unmap_window_request_t *)anEvent
{
	XCBWindow *window = [self windowForXCBId:anEvent->window];
	NSLog(@"[%@] Unmap request for window %u", NSStringFromClass([self class]), [window window]);
	xcb_unmap_window(connection, [window window]);
	[window setIsMapped:NO];
	[self setNeedFlush:YES];
}

- (void) handleConfigureWindowRequest:(xcb_configure_request_event_t *)anEvent
{
	uint16_t config_win_mask = 0;
    uint32_t config_win_vals[7];
    unsigned short i = 0;
	XCBWindow *window = [self windowForXCBId:anEvent->window];
	
	if (anEvent->value_mask & XCB_CONFIG_WINDOW_X)
	{
		config_win_mask |= XCB_CONFIG_WINDOW_X;
		config_win_vals[i++] = anEvent->x;
	}
	
	if (anEvent ->value_mask & XCB_CONFIG_WINDOW_Y)
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
	
	xcb_configure_window(connection, [window window], config_win_mask, config_win_vals);
}

- (void) handleMotionNotify:(xcb_motion_notify_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];
    
    if (dragState)
    {
        XCBWindow *frame = [window parentWindow];
        XCBPoint *pos = [[frame windowRect] position];
        XCBPoint *offset = [[frame windowRect] offset];
        
        int16_t x =  [pos getX];
        int16_t y = [pos getY];
        
        x = x + anEvent->event_x - [offset getX];
        y = y + anEvent->event_y - [offset getY];
        
        [pos setX:x];
        [pos setY:y];
        
        xcb_configure_window(connection, [frame window], XCB_CONFIG_WINDOW_X | XCB_CONFIG_WINDOW_Y, [pos values]);
        
        needFlush = YES;
        pos = nil;
        offset = nil;
    }
    
}

- (void) handleButtonPress:(xcb_button_press_event_t *)anEvent
{
    XCBWindow *window = [self windowForXCBId:anEvent->event];
    XCBWindow *parent = [window parentWindow];
    XCBPoint *offset = [[parent windowRect] offset];
    [offset setX:anEvent->event_x];
    [offset setY:anEvent->event_y];
    
    if ([parent window] != anEvent->root)
        dragState = YES;
    else
        dragState = NO;
    
    offset = nil;
    
    
}

- (void) handleButtonRelease:(xcb_button_release_event_t *)anEvent
{
   dragState = NO;
}

- (void) handleExpose:(xcb_expose_event_t *)anEvent
{
    /*XCBWindow *window;
    BOOL exists = NO;
    
    if (anEvent->count == 0)
    {
        return;
    }
    
    NSNumber *key = [[NSNumber alloc] initWithInt:anEvent->window];
    window = [windowsMap objectForKey: key];
    key = nil;
    
    if (window != nil)
    {
        NSLog(@"Window with id %u present in the windows map", [window window]);
        exists = YES;
    }
    
    // if already decorated for now just return, in future avoid to decorate but DO the other requests like redraw.
    if ([window decorated] && exists)
    {
        NSLog(@"Window with id %u already decorated", [window window]);
        return;
    }
    
    if ([window decorated] == NO && !exists)
    {
        window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window];
        XCBPoint *position = [[XCBPoint alloc] initWithX:1 andY:1];
        XCBSize *size = [[XCBSize alloc] initWithWidht:anEvent->width andHeight:anEvent->height];
        XCBRect *rect = [[XCBRect alloc] initWithPosition:position andSize:size];
        [window setWindowRect:rect];
        [self registerWindow:window];
    }
    
    //there are windows that exists in the windowsMap but shouldn't be decorated like menus. Make the appropriate check.
    
    XCBFrame *frame = [[XCBFrame alloc] initWithClientWindow:window withConnection:self];
    [frame decorateClientWindow];*/
    
}

- (void) handleReparentNotify:(xcb_reparent_notify_event_t *)anEvent
{
    // devo gestire questa notifica altirenti come riparento?
}

//TODO: tenere traccia del tempo per ogni evento.

- (xcb_timestamp_t)currentTime
{
    return currentTime;
}

- (void) setCurrentTime:(xcb_timestamp_t)time
{
    currentTime = time;
}

- (void) destroyWindow:(XCBWindow *)aWindow
{
    xcb_destroy_window(connection, [aWindow window]);
    needFlush = YES;
}

- (void) registerAsWindowManager:(BOOL)replace screenId:(uint32_t)screenId selectionWindow:(XCBWindow*)selectionWindow
{
    XCBScreen* screen = [screens objectAtIndex:0];
    
    uint32_t values[1];
    values[0] = XCB_EVENT_MASK_SUBSTRUCTURE_REDIRECT;
    XCBWindow* rootWindow = [[XCBWindow alloc] initWithXCBWindow:[[screen rootWindow] window]];
    
    if (replace) //gli attributi vanno cambiati sempre poi chekko se il replace è attivo e getto la selection.
    {
        BOOL attributesChanged = [self changeAttributes:values forWindow: rootWindow checked:YES];
    
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
            return;
        }
        
        NSLog(@"Subtructure redirect was set to the root window");
        return;
    }

    NSLog(@"Replacing window manager");
    
    NSString *atomName = [NSString stringWithFormat:@"WM_S%d", screenId];
    
    [[ewmhService atomService] cacheAtom:atomName];
    
    xcb_atom_t internedAtom = [[ewmhService atomService] atomFromCachedAtomsWithKey:atomName];
    
    XCBSelection* selector = [[XCBSelection alloc] initWithConnection:self andAtom:internedAtom];
  
    BOOL aquired = [selector aquireWithWindow:selectionWindow replace:replace];
    
    if (aquired)
    {
        BOOL attributesChanged = [self changeAttributes:values forWindow: rootWindow checked:YES];
        
        if (!attributesChanged)
        {
            NSLog(@"Can't register as window manager.");
            return;
        }
    }
    
    NSLog(@"Registered as window manager");
    
}

- (void) dealloc
{
    [screens removeAllObjects];
	screens = nil;
    [windowsMap removeAllObjects];
	windowsMap = nil;
	displayName = nil;
    xcb_disconnect(connection);
}


@end
