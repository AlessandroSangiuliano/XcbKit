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
    
    NSString* icccmAtoms[] =
    {
        WMProtocols,
        WMDeleteWindow,
        WMName
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
    
    xcb_atom_t* windowProtocols = (xcb_atom_t*)[self getProperty:WMProtocols
                                                    propertyType:XCB_GET_PROPERTY_TYPE_ANY
                                                       forWindow:window
                                                          delete:NO];
    
    int size = sizeof(windowProtocols)/ sizeof(windowProtocols);
    
    for(int i = 0; i < size; i++)
    {
        if (windowProtocols[i] == atom)
        hasProtocol = YES;
    }
    
    return hasProtocol;
}

- (void) dealloc
{
    WMDeleteWindow = nil;
    WMProtocols = nil;
    WMName = nil;
    atomsArray = nil;
}


@end
