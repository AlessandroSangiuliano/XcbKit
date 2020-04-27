//
//  XCBSelection.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 26/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBSelection.h"
#import "EWMHService.h"
#import "XCBAtomService.h"

@implementation XCBSelection

@synthesize connection;

- (id) initWithConnection:(XCBConnection *)aConnection andAtom:(xcb_atom_t)anAtom
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to allocate");
        return nil;
    }
    
    connection = aConnection;
    atom = anAtom;
    
    return self;
}


-(XCBWindow*) requestOwner
{
    xcb_get_selection_owner_cookie_t request = xcb_get_selection_owner([connection connection], atom);
    xcb_get_selection_owner_reply_t *reply = xcb_get_selection_owner_reply([connection connection],
                                                                           request,
                                                                           NULL);
    
    if (NULL == reply)
	{
        NSLog(@"Unable to get the owner");
        return nil;
	}
    
    XCBWindow *owner = reply->owner != XCB_NONE ? [[XCBWindow alloc] initWithXCBWindow:reply->owner andConnection:connection] : nil;
    [connection registerWindow:owner];
    
    free(reply);
    return owner;
}

- (void) setOwner:(XCBWindow *)aWindow
{
    xcb_timestamp_t currentTime = [connection currentTime];
    
    xcb_set_selection_owner([connection connection],
                            [aWindow window],
                            atom,
                            currentTime);
}

- (BOOL)aquireWithWindow:(XCBWindow *)aWindow replace:(BOOL)replace
{
    XCBWindow *currentOwner = [self requestOwner];
    BOOL aquired = NO;
    
    if (currentOwner != nil)
    {
        if (!replace)
			return NO;
        
        [self setOwner:aWindow];
        
        /* Wait for the old owner to go away */
        
        XCBRect *geometry = nil;
        
        do
        {
            geometry = nil;
            geometry = [connection geometryForWindow:currentOwner];
            
        } while (geometry != nil);
        
        aquired = YES;
    }
    
    /* Announce that we are the new owner */
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    xcb_client_message_event_t ev;
    ev.response_type = XCB_CLIENT_MESSAGE;
    ev.window = [screen screen]->root;
    ev.format = 32;
    ev.type = [[[[ewmhService atomService] cachedAtoms] objectForKey:[ewmhService MANAGER]] unsignedIntValue];
    ev.data.data32[0] = [connection currentTime];
    ev.data.data32[1] = atom;
    ev.data.data32[2] = [aWindow window];
    ev.data.data32[3] = ev.data.data32[4] = 0;
    
    xcb_send_event([connection connection], false, [screen screen]->root, 0xFFFFFF, (char*)&ev);
    
    screen = nil;
    ewmhService = nil;
    currentOwner = nil;
    
    return aquired;
}



/************
* ACCESSORS *
************/

- (void) setAtom:(xcb_atom_t)anAtom
{
    atom = anAtom;
}

- (xcb_atom_t) getAtom
{
    return atom;
}

- (void) dealloc
{
    connection = nil;
}
@end
