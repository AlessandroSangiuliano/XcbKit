//
//  Pova.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 12/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "ICCCMService.h"

@implementation ICCCMService

@synthesize WMDeleteWindow;
@synthesize WMProtocols;
@synthesize atomsArray;
@synthesize WMName;
@synthesize WMNormalHints;
@synthesize WMSizeHints;
@synthesize WMTakeFocus;
@synthesize WMState;
@synthesize WMHints;
@synthesize WMChangeState;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super initWithConnection:aConnection];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    WMDeleteWindow = @"WM_DELETE_WINDOW";
    WMProtocols = @"WM_PROTOCOLS";
    WMTakeFocus = @"WM_TAKE_FOCUS";
    WMName = @"WM_NAME";
    WMNormalHints = @"WM_NORMAL_HINTS";
    WMSizeHints = @"WM_SIZE_HINS";
    WMState = @"WM_STATE";
    WMHints = @"WM_HINTS";
    WMChangeState = @"WM_CHANGE_STATE";
    
    NSString* icccmAtoms[] =
    {
        WMProtocols,
        WMDeleteWindow,
        WMName,
        WMNormalHints,
        WMSizeHints,
        WMTakeFocus,
        WMState,
        WMHints,
        WMChangeState
    };
    
    atomsArray = [NSArray arrayWithObjects:icccmAtoms count:sizeof(icccmAtoms)/sizeof(NSString*)];
    [[super atomService] cacheAtoms:atomsArray];
    
    return self;
}

+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection
{
    static ICCCMService* sharedInstance;
    
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] initWithConnection:aConnection];
    }
    
    return sharedInstance;
}

- (BOOL) hasProtocol:(NSString *)protocol forWindow:(XCBWindow*)window
{
    BOOL hasProtocol = NO;
    
    xcb_atom_t atom = [[super atomService] atomFromCachedAtomsWithKey:protocol];

    xcb_get_property_reply_t* reply = [self getProperty:WMProtocols
                                           propertyType:XCB_GET_PROPERTY_TYPE_ANY
                                              forWindow:window
                                                 delete:NO
                                                 length:UINT32_MAX];

    xcb_atom_t* windowProtocols = xcb_get_property_value(reply);

    for(int i = 0; i < reply->length; i++)
    {
        if (windowProtocols[i] == atom)
            hasProtocol = YES;
    }
    
    windowProtocols = NULL;
    free(reply);
    return hasProtocol;
}

- (xcb_size_hints_t*) wmNormalHintsForWindow:(XCBWindow *)aWindow
{
    xcb_connection_t *connection = [[aWindow connection] connection];
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_normal_hints(connection, [aWindow window]);
    
    xcb_size_hints_t *sizeHints = malloc(sizeof(xcb_size_hints_t));
    
    xcb_icccm_get_wm_normal_hints_reply(connection, cookie, sizeHints, NULL);
    
    connection = NULL;
    return sizeHints;
}

- (void)updateWMNormalHints:(xcb_size_hints_t*)sizeHints forWindow:(XCBWindow*)aWindow
{
    xcb_icccm_set_wm_size_hints([[aWindow connection] connection], [aWindow window], XCB_ATOM_WM_NORMAL_HINTS, sizeHints);
}

- (NSString*) getWmNameForWindow:(XCBWindow *)aWindow
{
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_name([[aWindow connection] connection], [aWindow window]);
    xcb_icccm_get_text_property_reply_t property;
    
    xcb_icccm_get_wm_name_reply([[aWindow connection] connection],
                                cookie,
                                &property,
                                NULL);
    NSString* name;
    if (property.name != NULL)
        name = [NSString stringWithCString:property.name encoding:NSASCIIStringEncoding];
    
    return name;
}

- (xcb_icccm_wm_hints_t) wmHintsFromWindow:(XCBWindow*)aWindow
{
    xcb_icccm_wm_hints_t wmHints;
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_hints([[super connection] connection],
                                                              [aWindow window]);
    uint8_t success = xcb_icccm_get_wm_hints_reply([[super connection] connection],
                                                   cookie,
                                                   &wmHints,
                                                   NULL);

    if (!success)
        NSLog(@"Error: Can't fill wmHints structure!");

    return wmHints;
}

- (void) setWMStateForWindow:(XCBWindow*)aWindow state:(WindowState)state
{
    xcb_atom_t atom = [[super atomService] atomFromCachedAtomsWithKey:WMState];
    uint32_t data[] = { state, XCB_NONE };

    [super changePropertiesForWindow:aWindow
                            withMode:XCB_PROP_MODE_REPLACE
                        withProperty:WMState
                            withType:atom
                          withFormat:32
                      withDataLength:2
                            withData:data];
}

- (void) wmClassForWindow:(XCBWindow*)aWindow
{
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_class_unchecked([[super connection] connection], [aWindow window]);
    xcb_icccm_get_wm_class_reply_t reply;

    if (!xcb_icccm_get_wm_class_reply([[super connection] connection],
                                      cookie,
                                      &reply, NULL))
    {
        NSLog(@"Error while checking WM_CLASS");
        return;
    }

    [[aWindow windowClass] addObject:[[NSString alloc] initWithCString:reply.class_name]];
    [[aWindow windowClass] addObject:[[NSString alloc] initWithCString:reply.instance_name]];

    xcb_icccm_get_wm_class_reply_wipe(&reply);
}

- (void) dealloc
{
    WMDeleteWindow = nil;
    WMProtocols = nil;
    WMName = nil;
    atomsArray = nil;
    WMTakeFocus = nil;
    WMSizeHints = nil;
    WMHints = nil;
    WMState = nil;
    WMNormalHints = nil;
}


@end
