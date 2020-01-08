//
//  XCBAtomService.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#import <xcb.h>

// Singleton

@interface XCBAtomService : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (nonatomic) NSMutableDictionary *cachedAtoms;


+ (id) sharedInstanceWithConnection:(XCBConnection*) aConnection;

- (void) cacheAtom:(NSString*) atomName;
- (void) cacheAtoms:(NSArray*) atoms;

- (void) dealloc;

@end