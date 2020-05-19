//
//  XCBRegion.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 30/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//


#import "XCBRegion.h"


@implementation XCBRegion

@synthesize regionId;
@synthesize connection;
@synthesize rectanglesNumber;
@synthesize rectangles;


- (id) initWithConnection:(XCBConnection *)aConnection
{
    return [self initWithConnection:aConnection regionId:XCB_NONE];
}

- (id) initWithConnection:(XCBConnection *)aConnection regionId:(xcb_xfixes_region_t)aRegionId
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init");
        return nil;
    }
    
    connection = aConnection;
    className = NSStringFromClass([self class]);
    
    if (aRegionId == XCB_NONE)
        regionId = xcb_generate_id([connection connection]);
    else
        regionId = aRegionId;
    
    
    return self;

}

- (id) initWithConnection:(XCBConnection *)aConnection rectagles:(xcb_rectangle_t *)rects count:(int)rectsNumber
{
    self = [self initWithConnection:aConnection];
    
    rectanglesNumber = rectsNumber;
    rectangles = rects;
    
    xcb_xfixes_create_region([connection connection],
                             regionId,
                             rectanglesNumber,
                             rectangles);
    
    return self;
}

- (BOOL) initXFixesProtocol
{
    /*** INIT THE EXTENSION XFIXES ***/
    
    static const char* extensionName = "XFIXES";
    
    xcb_query_extension_reply_t* reply;
    xcb_query_extension_cookie_t cookie = xcb_query_extension([connection connection], strlen(extensionName), extensionName);
    reply = xcb_query_extension_reply([connection connection], cookie, NULL);
    
    if (!reply->present)
    {
        NSLog(@"The server doens't support the extension");
        return NO;
    }
    
    /*** CHECK THE XFIXES VERSION ***/
    
    xcb_xfixes_query_version_cookie_t version = xcb_xfixes_query_version([connection connection],
                                                                         XCB_XFIXES_MAJOR_VERSION,
                                                                         XCB_XFIXES_MINOR_VERSION);
    
    xcb_xfixes_query_version_reply_t* versionReply = xcb_xfixes_query_version_reply([connection connection],
                                                                                    version,
                                                                                    NULL);
    BOOL checkVersion = NO;
    
    if (versionReply->major_version > XCB_XFIXES_MAJOR_VERSION)
        checkVersion = YES;
    else if (XCB_XFIXES_MAJOR_VERSION == versionReply->major_version && versionReply->minor_version >= XCB_XFIXES_MINOR_VERSION)
        checkVersion = YES;
    
    if (!checkVersion)
    {
        NSLog(@"No xfifes extension for the required version");
        return NO;
    }
    
    NSLog(@"XFixes extension initialized with version %d.%d", versionReply->major_version, versionReply->minor_version);
    
    free(reply);
    free(versionReply);
    
    return YES;
}

- (void) unionWithRegion:(XCBRegion *)secondSource destination:(XCBRegion *)destination
{
    if (regionId == XCB_NONE)
    {
        NSLog(@" [%@:] First source has no region id", className);
        return;
    }
    
    xcb_xfixes_union_region([connection connection], [self regionId], [secondSource regionId], [destination regionId]);
    
    return;
}

- (void) dealloc
{
    xcb_xfixes_destroy_region([connection connection], regionId);
    connection = nil;
    className = nil;
}

@end
