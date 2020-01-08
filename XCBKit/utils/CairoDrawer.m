//
//  CairoDrawer.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 02/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "CairoDrawer.h"
#import "XCBScreen.h"

@implementation CairoDrawer

@synthesize cairoSurface;
@synthesize cr;
@synthesize connection;
@synthesize window;
@synthesize visual;
@synthesize height;
@synthesize width;

- (id) initWithConnection:(XCBConnection *)aConnection
{
    return [self initWithConnection:aConnection window:nil visual:nil];
}

- (id) initWithConnection:(XCBConnection *)aConnection window:(XCBWindow *)aWindow visual:(XCBVisual *)aVisual
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init");
        return nil;
    }
    
    connection = aConnection;
    window = aWindow;
    visual = aVisual;
    
    height = [[[window windowRect] size] getHeight];
    width = [[[window windowRect] size] getWidth];
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    
    [visual setVisualTypeForScreen:screen];
    
    screen = nil;
    
    return self;
}

- (void) drawTitleBarButtonWithColor:(NSColor *)buttonColor withStopColor:(NSColor *)stopColor
{
    height = height - 2;
    width = width - 2;
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, [buttonColor redComponent], [buttonColor greenComponent], [buttonColor blueComponent]);
    
    CGFloat startXPosition = 2;
    CGFloat endXPosition = 2;
    CGFloat startYPosition = 1;
    CGFloat endYPosition = height + 2;
    
    CGFloat stopGradientOffset = 0.9;
    CGFloat colorGradientOffset = 0.1;
    
    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, [buttonColor redComponent], [buttonColor greenComponent], [buttonColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    
    cairo_set_source(cr, pat);
    
    CGFloat xPosition = width / 2;
    CGFloat yPosition = height / 2;
    CGFloat radius = (CGFloat) height / 2.0;
    
    cairo_arc (cr, xPosition, yPosition, radius, 0  * (M_PI / 180.0), 360 * (M_PI / 180.0));
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);
    
    cairo_set_line_width (cr, 0.2);
    
    cairo_arc (cr, xPosition, yPosition, radius, 0  * (M_PI / 180.0), 360 * (M_PI / 180.0));
    
    NSColor *black = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:1];
    cairo_set_source_rgb(cr, [black redComponent], [black greenComponent], [black blueComponent]);
    cairo_stroke(cr);
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
    
    

}

- (void) drawTitleBarWithColor:(NSColor *)titleColor andStopColor :(NSColor *)stopColor
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height-1);
    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, [titleColor redComponent], [titleColor greenComponent], [titleColor blueComponent]);
    
    CGFloat startXPosition = 0;
    CGFloat endXPosition = 0;
    CGFloat startYPosition = height;
    CGFloat endYPosition = [[[window windowRect] position] getY];;
    
    CGFloat stopGradientOffset = 0.99;
    CGFloat colorGradientOffset = 0.2;

    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, [titleColor redComponent], [titleColor greenComponent], [titleColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    
    
    cairo_set_source(cr, pat);
    
    cairo_rectangle(cr, [[[window windowRect] position] getX], [[[window windowRect] position] getY], width, height-1);
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);

}

- (void) drawWindowWithColor:(NSColor*)aColor andStopColor:(NSColor*)stopColor
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, [aColor redComponent], [aColor greenComponent], [aColor blueComponent]);
    
    CGFloat startXPosition = 0;
    CGFloat endXPosition = 0;
    CGFloat startYPosition = height;
    CGFloat endYPosition = -3;
    
    CGFloat stopGradientOffset = 0.99;
    CGFloat colorGradientOffset = 0.2;
    
    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, [aColor redComponent], [aColor greenComponent], [aColor blueComponent]);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, [stopColor redComponent], [stopColor greenComponent], [stopColor blueComponent]);
    
    
    cairo_set_source(cr, pat);
    
    cairo_rectangle(cr, 0, 0, width, height);
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);

}

- (void) dealloc
{
    cairoSurface = NULL;
    cr = NULL;
    connection = nil;
    window = nil;
    visual = nil;
    height =  0.0;
    width = 0.0;
}

@end
