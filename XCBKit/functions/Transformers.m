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

XCBFrame * FnFromXCBWindowToXCBFrame(XCBWindow* aWindow, XCBConnection* connection)
{
    XCBFrame *frame = [[XCBFrame alloc] init];
    
    [frame setAboveWindow:[aWindow aboveWindow]];
    [frame setWindow:[aWindow window]];
    [frame setParentWindow:[aWindow parentWindow]];
    [frame setAttributes:[aWindow attributes]];
    [frame setWindowRect:[aWindow windowRect]];
    [frame setWindowMask:[aWindow windowMask]];
    [frame setIsMapped:[aWindow isMapped]];
    [frame setConnection:connection];
    
    
    return frame;
}

XCBTitleBar* FnFromXCBWindowToXCBTitleBar(XCBWindow *aWindow, XCBConnection* connection)
{
    XCBTitleBar *titleBar = [[XCBTitleBar alloc] init];
    
    [titleBar setAboveWindow:[aWindow aboveWindow]];
    [titleBar setWindow:[aWindow window]];
    [titleBar setParentWindow:[aWindow parentWindow]];
    [titleBar setAttributes:[aWindow attributes]];
    [titleBar setWindowRect:[aWindow windowRect]];
    [titleBar setWindowMask:[aWindow windowMask]];
    [titleBar setIsMapped:[aWindow isMapped]];
    [titleBar setConnection:connection];
    [titleBar setTitlebarColor:[NSColor colorWithCalibratedRed:0.720 green:0.720 blue:0.720 alpha:1]];
    
    return titleBar;

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

void CsMapXCBWindowToXCBTitleBar(XCBWindow* sourceWindow, XCBTitleBar* titleBar)
{
    [titleBar setAboveWindow:[sourceWindow aboveWindow]];
    [titleBar setWindow:[sourceWindow window]];
    [titleBar setParentWindow:[sourceWindow parentWindow]];
    [titleBar setAttributes:[sourceWindow attributes]];
    [titleBar setWindowRect:[sourceWindow windowRect]];
    [titleBar setWindowMask:[sourceWindow windowMask]];
    [titleBar setIsMapped:[sourceWindow isMapped]];
    [titleBar setTitlebarColor:[NSColor colorWithCalibratedRed:0.720 green:0.720 blue:0.720 alpha:1]];
}

XCBWindow * FnFromExposeEventToXCBWindow(xcb_expose_event_t *anEvent, XCBConnection* connection)
{
    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window andConnection:connection];
    
    XCBSize *size = [[XCBSize alloc] initWithWidht:anEvent->window andHeight:anEvent->height];
    XCBPoint *point = [[XCBPoint alloc] initWithX:anEvent->x andY:anEvent->y];
    XCBRect *rect = [[XCBRect alloc] initWithPosition:point andSize:size];
    
    [window setWindowRect:rect];
    
    return window;
}

@end
