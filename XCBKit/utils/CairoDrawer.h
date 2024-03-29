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
#import "../XCBWindow.h"
#import "../XCBVisual.h"
#import "XCBShape.h"

@interface CairoDrawer : NSObject

@property (nonatomic) cairo_surface_t *cairoSurface;
@property (nonatomic) cairo_t *cr;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBWindow *window;
@property (strong, nonatomic) XCBVisual *visual;
@property (nonatomic) CGFloat height;
@property (nonatomic) CGFloat width;
@property (nonatomic) BOOL alreadyScaled; //could be useful only for tests

- (id) initWithConnection:(XCBConnection*) aConnection;
- (id) initWithConnection:(XCBConnection *)aConnection window:(XCBWindow*) aWindow visual:(XCBVisual*) aVisual;
- (id) initWithConnection:(XCBConnection *)aConnection window:(XCBWindow*) aWindow;
- (void) drawTitleBarButtonWithColor:(XCBColor) buttonColor withStopColor:(XCBColor) stopColor;
- (void) drawTitleBarWithColor:(XCBColor) titleColor andStopColor:(XCBColor) stopColor;
- (void) drawWindowWithColor:(XCBColor)aColor andStopColor:(XCBColor)stopColor;
- (void) drawText:(NSString*) aText withColor:(XCBColor) aColor;
- (void) makePreviewImage;
- (void) saveContext;
- (void) restoreContext;
- (void) setPreviewImage;
- (void) putImage:(NSString*)aPath forDPixmap:(BOOL)aValue;
- (void) drawContent;
- (cairo_surface_t*) drawContentFromData:(uint32_t *)data withWidht:(int)aWidth andHeight:(int)aHeight;
- (void) drawIconFromSurface:(cairo_surface_t*)aSurface;
@end
