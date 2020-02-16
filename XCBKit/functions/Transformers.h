//
//  Transformers.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 11/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBAtomService.h"
#import <xcb_atom.h>
#import "XCBWindow.h"
#import "XCBFrame.h"

@interface Transformers : NSObject

xcb_atom_t * FnFromNSArrayAtomsToXcbAtomTArray(NSArray *array, XCBAtomService *atomService);

/***Transforms a window in a frame ***/

XCBFrame* FnFromXCBWindowToXCBFrame(XCBWindow* aWindow);

/*** Bi-Consumer that map a window to a frame ***/

void CsMapXCBWindoToXCBFrame(XCBWindow* sourceWindow, XCBFrame *destFrame);

XCBWindow* FnFromExposeEventToXCBWindow(xcb_expose_event_t *anEvent);

@end
