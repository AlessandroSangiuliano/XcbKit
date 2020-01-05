//
//  CairoDrawer.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 02/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <cairo/cairo-xcb.h>
#import <cairo/cairo.h>
#import <XCBConnection.h>
#import "XCBWindow.h"
#import "XCBVisual.h"

@interface CairoDrawer : NSObject

@property (nonatomic) cairo_surface_t *cairoSurface;
@property (nonatomic) cairo_t *cr;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBWindow *window;
@property (strong, nonatomic) XCBVisual *visual;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;

- (id) initWithConnection:(XCBConnection*) aConnection;
- (id) initWithConnection:(XCBConnection *)aConnection window:(XCBWindow*) aWindow visual:(XCBVisual*) aVisual;
- (void) drawTitleBarButtonWithColor:(NSColor*) buttonColor withStopColor:(NSColor*) stopColor;
- (void) drawTitleBarWithColor:(NSColor*) titleColor andStopColor:(NSColor*) stopColor;
- (void) drawWindowWithColor:(NSColor*)aColor andStopColor:(NSColor*)stopColor;

@end
