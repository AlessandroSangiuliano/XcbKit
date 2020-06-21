//
//  XCBSelection.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 26/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#import <xcb/xcb.h>


@interface XCBSelection : NSObject
{
    xcb_atom_t atom;
}

@property (nonatomic, strong) XCBConnection* connection;

- (id) initWithConnection:(XCBConnection*)aConnection andAtom:(xcb_atom_t) anAtom;
- (void) setOwner:(XCBWindow*)aWindow;
- (XCBWindow*) requestOwner;
- (BOOL) aquireWithWindow:(XCBWindow*)aWindow replace:(BOOL)replace;


- (void) setAtom:(xcb_atom_t)anAtom;
- (xcb_atom_t) getAtom;

@end
