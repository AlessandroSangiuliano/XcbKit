    //
//  XCBConnection.m
//  XCBKit
//
//  Created by alex on 27/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBConnection.h"

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

		xcb_screen_next(&iterator);
	}
	
    XCBConn = self;
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
	NSLog(@"[XCBConnection] Adding the window in the windowsMap");
    [windowsMap setObject:aWindow forKey:[[NSNumber alloc] initWithInt:[aWindow window]]];
}

- (void) unregisterWindow:(XCBWindow *)aWindow
{
	NSLog(@"[XCBConnection] Removing the window from the windowsMap");
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
	return winToCreate;

}

- (void) mapWindow:(XCBWindow *)aWindow
{
    xcb_map_window(connection, [aWindow window]);
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
	XCBWindow *window = [self windowForXCBId:anEvent->window];
	NSLog(@"[%@] Map request for window %u", NSStringFromClass([self class]), [window window]);
	xcb_map_window(connection, [window window]);
	[window setIsMapped:YES];
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

- (void) handleMotionNotify:(xcb_motion_notify_event_t *)anEvent forWindow:(XCBWindow*) aWindow
{
    //TODO: è sempre uguale studiare perchè la windows ocn l'event (dopo ho messo il parametro aWindow dovrebbe avere più senso
    if ([aWindow window] == anEvent->event && dragState)
    {
        XCBWindow *frame = [aWindow parentWindow];
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

- (void) handleButtonPress:(xcb_button_press_event_t *)anEvent forWindow:(XCBWindow*) aWindow
{
    // è sempre uguale studiare perchè la windows ocn l'event
    if (anEvent->event == [aWindow window])
    {
        XCBWindow *frame = [aWindow parentWindow];
        XCBPoint *offset = [[frame windowRect] offset];
        NSLog(@"Ciao");
        [offset setX:anEvent->event_x];
        [offset setY:anEvent->event_y];
        dragState = YES;
        offset = nil;
    }
    
}

- (void) handleButtonRelease:(xcb_button_release_event_t *)anEvent
{
   dragState = NO;
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
