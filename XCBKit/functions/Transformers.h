//
//  Transformers.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 11/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../services/XCBAtomService.h"
#import "../utils/XCBShape.h"
#import "../XCBWindow.h"
#import "../XCBFrame.h"
#import "../XCBTitleBar.h"
#import "../XCBConnection.h"

@interface Transformers : NSObject

void FnFromNSArrayAtomsToXcbAtomTArray(NSArray *array, xcb_atom_t destinaton[], XCBAtomService *atomService);

/***Transforms a window in a frame ***/

XCBFrame* FnFromXCBWindowToXCBFrame(XCBWindow* aWindow, XCBConnection* connection, XCBWindow *clientWindow);

/*** Transforms a window to a title bar ***/

XCBTitleBar* FnFromXCBWindowToXCBTitleBar(XCBWindow *aWindow, XCBConnection* connection);

/*** Bi-Consumer that map a window to a frame ***/

void CsMapXCBWindoToXCBFrame(XCBWindow* sourceWindow, XCBFrame *destFrame);

/*** Bi-Consumer that map a generic XCBWindow to a TitleBar **/

void CsMapXCBWindowToXCBTitleBar(XCBWindow* sourceWindow, XCBTitleBar* titleBar);

XCBWindow* FnFromExposeEventToXCBWindow(xcb_expose_event_t *anEvent, XCBConnection* connection);

/*** Transform a NSInteger to NSString ***/

NSString *FnFromNSIntegerToNSString(NSInteger value);

/*** Delete a window from an array of xcb_window_t ***/

BOOL FnRemoveWindowFromWindowsArray(xcb_window_t windows[], int arraySize, xcb_window_t windowToRemove);

@end
