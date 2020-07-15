//
//  XCBAtomService.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#import <xcb/xcb.h>

@class XCBConnection;
// Singleton

@interface XCBAtomService : NSObject
{
}

@property (strong, nonatomic) XCBConnection *connection;
@property (nonatomic) NSMutableDictionary *cachedAtoms;


+ (id) sharedInstanceWithConnection:(XCBConnection*) aConnection;

- (xcb_atom_t) cacheAtom:(NSString*) atomName;
- (void) cacheAtoms:(NSArray*) atoms;
- (xcb_atom_t) atomFromCachedAtomsWithKey:(NSString*) atomName;
- (NSNumber*) atomNumberFromCachedAtomsWithKey:(NSString*) atomName;
- (NSString*) atomNameFromAtom:(xcb_atom_t)anAtom;

- (void) dealloc;

@end
