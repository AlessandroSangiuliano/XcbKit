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
@synthesize cachedAtoms;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    connection = aConnection;
    cachedAtoms = [[NSMutableDictionary alloc] init];
    
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

- (void) cacheAtom:(NSString*) atomName
{
    if ([cachedAtoms objectForKey:atomName] != nil)
    {
        NSLog(@"Atom previously cached!");
        return;
    }
    
    const char *str = [atomName UTF8String];
    xcb_intern_atom_cookie_t cookie = xcb_intern_atom([connection connection], NO, strlen(str), str);
    xcb_intern_atom_reply_t* reply = xcb_intern_atom_reply([connection connection], cookie, NULL);
    xcb_atom_t atom = reply->atom;
    NSNumber *atomValue = [NSNumber numberWithUnsignedInt:atom];
    [cachedAtoms setObject:atomValue forKey:atomName];
    
    //free(reply)?
}

- (void) cacheAtoms:(NSArray *)atoms
{
    NSUInteger size = [atoms count];
   
    for (NSUInteger i = 0; i < size; i++)
    {
        NSString *atomName = [atoms objectAtIndex:i];
        [self cacheAtom:atomName];
    }
    
}

- (xcb_atom_t) atomFromCachedAtomsWithKey:(NSString *)atomName
{
    return [[cachedAtoms objectForKey:atomName] unsignedIntValue];
}

- (void) dealloc
{
    connection = nil;
    cachedAtoms = nil;
}

@end
