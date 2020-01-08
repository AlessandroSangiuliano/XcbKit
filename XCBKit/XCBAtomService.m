//
//  XCBAtomService.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBAtomService.h"

@implementation XCBAtomService

@synthesize connection;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    connection = aConnection;
    
    return self;
}

+ (id) sharedInstanceWithConnection:(XCBConnection *)aConnection
{
    static XCBAtomService *sharedInstance = nil;
    
    //Not thread safe
    
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] initWithConnection:aConnection];
    }
    
    return sharedInstance;
}

- (void) dealloc
{
    connection = nil;
}

@end
