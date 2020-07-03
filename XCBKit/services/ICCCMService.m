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
    WMName = @"WM_NAME";
    WMNormalHints = @"WM_NORMAL_HINTS";
    WMSizeHints = @"WM_SIZE_HINS";
    
    NSString* icccmAtoms[] =
    {
        WMProtocols,
        WMDeleteWindow,
        WMName,
        WMNormalHints,
        WMSizeHints
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
    
    void* reply = [self getProperty:WMProtocols
                       propertyType:XCB_GET_PROPERTY_TYPE_ANY
                          forWindow:window
                             delete:NO];

    xcb_atom_t* windowProtocols = xcb_get_property_value(reply);
    
    int size = sizeof(windowProtocols)/ sizeof(windowProtocols);
    
    for(int i = 0; i < size; i++)
    {
        if (windowProtocols[i] == atom)
            hasProtocol = YES;
    }
    
    free(windowProtocols);
    free(reply);
    return hasProtocol;
}

- (xcb_size_hints_t*) wmNormalHintsForWindow:(XCBWindow *)aWindow
{
    xcb_connection_t *connection = [[aWindow connection] connection];
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_normal_hints(connection, [aWindow window]);
    
    xcb_size_hints_t* sizeHints = malloc(sizeof(xcb_size_hints_t));
    
    xcb_icccm_get_wm_normal_hints_reply(connection, cookie, sizeHints, NULL);
    
    connection = NULL;
    return sizeHints;
}

- (NSString*) getWmNameForWindow:(XCBWindow *)aWindow
{
    xcb_get_property_cookie_t cookie = xcb_icccm_get_wm_name([[aWindow connection] connection], [aWindow window]);
    xcb_icccm_get_text_property_reply_t* property = malloc(sizeof(xcb_icccm_get_text_property_reply_t));
    
    xcb_icccm_get_wm_name_reply([[aWindow connection] connection],
                                cookie,
                                property,
                                NULL);
    
    NSString *name = [NSString stringWithCString:property->name encoding:NSASCIIStringEncoding];
    
    free(property);
    return name;
}

- (void) dealloc
{
    WMDeleteWindow = nil;
    WMProtocols = nil;
    WMName = nil;
    atomsArray = nil;
}


@end
