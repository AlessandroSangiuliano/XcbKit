//
//  Transformers.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 11/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "Transformers.h"


@implementation Transformers

xcb_atom_t * FnFromNSArrayAtomsToXcbAtomTArray(NSArray *array, XCBAtomService *atomService)
{
    NSUInteger size = [array count];
    xcb_atom_t *transformed = calloc(size, sizeof(xcb_atom_t));
    
    NSDictionary *cachedAtoms = [atomService cachedAtoms];
    
    for (NSUInteger i = 0; i < size; i++)
    {
        NSString *key = [array objectAtIndex:i];
        transformed[i] = [[cachedAtoms objectForKey:key] unsignedIntValue];
    }
    
    return transformed;
}

XCBFrame * FnFromXCBWindowToXCBFrame(XCBWindow* aWindow)
{
    XCBFrame *frame = [[XCBFrame alloc] init];
    
    [frame setAboveWindow:[aWindow aboveWindow]];
    [frame setWindow:[aWindow window]];
    [frame setParentWindow:[aWindow parentWindow]];
    [frame setAttributes:[aWindow attributes]];
    [frame setWindowRect:[aWindow windowRect]];
    [frame setWindowMask:[aWindow windowMask]];
    [frame setIsMapped:[aWindow isMapped]];
    
    return frame;
}

void CsMapXCBWindoToXCBFrame(XCBWindow* sourceWindow, XCBFrame *destFrame)
{
    [destFrame setAboveWindow:[sourceWindow aboveWindow]];
    [destFrame setWindow:[sourceWindow window]];
    [destFrame setParentWindow:[sourceWindow parentWindow]];
    [destFrame setAttributes:[sourceWindow attributes]];
    [destFrame setWindowRect:[sourceWindow windowRect]];
    [destFrame setWindowMask:[sourceWindow windowMask]];
    [destFrame setIsMapped:[sourceWindow isMapped]];
}

XCBWindow * FnFromExposeEventToXCBWindow(xcb_expose_event_t *anEvent)
{
    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window];
    
    XCBSize *size = [[XCBSize alloc] initWithWidht:anEvent->window andHeight:anEvent->height];
    XCBPoint *point = [[XCBPoint alloc] initWithX:anEvent->x andY:anEvent->y];
    XCBRect *rect = [[XCBRect alloc] initWithPosition:point andSize:size];
    
    [window setWindowRect:rect];
    
    return window;
}

@end
