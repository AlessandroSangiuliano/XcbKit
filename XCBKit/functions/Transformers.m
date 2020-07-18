//
//  Transformers.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 11/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "Transformers.h"


@implementation Transformers

void FnFromNSArrayAtomsToXcbAtomTArray(NSArray *array, xcb_atom_t destination[], XCBAtomService *atomService)
{
    NSUInteger size = [array count];
    
    NSDictionary *cachedAtoms = [atomService cachedAtoms];
    
    for (NSUInteger i = 0; i < size; i++)
    {
        NSString *key = [array objectAtIndex:i];
        destination[i] = [[cachedAtoms objectForKey:key] unsignedIntValue];
        key = nil;
    }
    
    cachedAtoms = nil;
}

XCBFrame * FnFromXCBWindowToXCBFrame(XCBWindow* aWindow, XCBConnection* connection, XCBWindow *clientWindow)
{
    XCBFrame *frame = [[XCBFrame alloc] initWithClientWindow:clientWindow withConnection:connection withXcbWindow:[aWindow window]];
    
    [frame setAboveWindow:[aWindow aboveWindow]];
    [frame setParentWindow:[aWindow parentWindow]];
    [frame setAttributes:[aWindow attributes]];
    [frame setWindowRect:[aWindow windowRect]];
    [frame setOriginalRect:[aWindow originalRect]];
    [frame setWindowMask:[aWindow windowMask]];
    [frame setIsMapped:[aWindow isMapped]];
    
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
    [titleBar setOriginalRect:[aWindow originalRect]];
    [titleBar setWindowMask:[aWindow windowMask]];
    [titleBar setIsMapped:[aWindow isMapped]];
    [titleBar setConnection:connection];
    [titleBar setTitleBarUpColor:XCBMakeColor(0.720, 0.720, 0.720, 1)];
    [titleBar setTitleBarDownColor:XCBMakeColor(0.898, 0.898, 0.898, 1)];
    
    return titleBar;
    
}

void CsMapXCBWindoToXCBFrame(XCBWindow* sourceWindow, XCBFrame *destFrame)
{
    [destFrame setAboveWindow:[sourceWindow aboveWindow]];
    [destFrame setWindow:[sourceWindow window]];
    [destFrame setParentWindow:[sourceWindow parentWindow]];
    [destFrame setAttributes:[sourceWindow attributes]];
    [destFrame setWindowRect:[sourceWindow windowRect]];
    [destFrame setOriginalRect:[sourceWindow originalRect]];
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
    [titleBar setOriginalRect:[sourceWindow originalRect]];
    [titleBar setWindowMask:[sourceWindow windowMask]];
    [titleBar setIsMapped:[sourceWindow isMapped]];
    [titleBar setTitleBarUpColor:XCBMakeColor(0.720, 0.720, 0.720, 1)];
    [titleBar setTitleBarDownColor:XCBMakeColor(0.898, 0.898, 0.898, 1)];
}

XCBWindow * FnFromExposeEventToXCBWindow(xcb_expose_event_t *anEvent, XCBConnection* connection)
{
    XCBWindow *window = [[XCBWindow alloc] initWithXCBWindow:anEvent->window andConnection:connection];
    
    XCBSize size = XCBMakeSize(anEvent->width, anEvent->height);
    XCBPoint point = XCBMakePoint(anEvent->x, anEvent->y);
    XCBRect rect = XCBMakeRect(point, size);
    
    [window setWindowRect:rect];
    
    return window;
}

@end
