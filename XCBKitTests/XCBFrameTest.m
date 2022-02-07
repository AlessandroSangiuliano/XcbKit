//
//  XCBFrameTest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBFrameTest.h"
#import "XCBFrame.h"
#import "XCBTitleBar.h"
#import "XCBConnection.h"
#import <cairo/cairo.h>
#import <cairo/cairo-xcb.h>
#import "Transformers.h"

@implementation XCBFrameTest

- (void) testFrame
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBWindow *clientWindow = [[XCBWindow alloc] initWithXCBWindow:xcb_generate_id([connection connection]) andConnection:connection];
    XCBPoint coordinates = XCBMakePoint(1, 1);
    XCBSize sizes = XCBMakeSize(300, 300);
    XCBRect windowRect = XCBMakeRect(coordinates, sizes);
    [clientWindow setWindowRect:windowRect];
    
    
    XCBSize frameSize = XCBMakeSize(sizes.width+1, sizes.height+1);
    
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    uint32_t values[2] = {[screen screen]->white_pixel, XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_STRUCTURE_NOTIFY
        | XCB_EVENT_MASK_BUTTON_RELEASE | XCB_EVENT_MASK_KEY_PRESS | XCB_EVENT_MASK_BUTTON_MOTION};
    
    
    XCBWindow *frameWindow = [connection createWindowWithDepth:[screen screen]->root_depth
                                              withParentWindow:[screen rootWindow]
                                                 withXPosition:coordinates.x
                                                 withYPosition:coordinates.y
                                                     withWidth:frameSize.width
                                                    withHeight:frameSize.height
                                              withBorrderWidth:10
                                                  withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                                  withVisualId:visual
                                                 withValueMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK
                                                 withValueList:values];
    
    /*XCBFrame *frame = [[XCBFrame alloc] initWithClientWindow:clientWindow
     withConnection:connection
     withXcbWindow:[frameWindow window]];*/
    
    /*XCBRect *frameRect = [[XCBRect alloc] initWithPosition:coordinates andSize: frameSize];
     [frame setWindowRect:frameRect];*/
    
    XCBFrame *frame = FnFromXCBWindowToXCBFrame(frameWindow, connection, clientWindow);
    
    //TODO: FUNZIONE CHE MAPPA UNA XCBWINDOW TO UN XCBFRAME
    
    /*[frame setParentWindow:[frameWindow parentWindow]];
     [frame setAboveWindow:[frameWindow aboveWindow]];
     [frame setIsMapped:[frameWindow isMapped]];
     [frame setAttributes:[frameWindow attributes]];*/
    
    frameWindow = nil;
    
    [connection mapWindow:frame];
    
    XCBTitleBar *titleBar = [[XCBTitleBar alloc] initWithFrame:frame withConnection:connection];
    [frame addChildWindow:titleBar withKey:TitleBar];
    
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    const char *windowName = "Scemo";
    
    xcb_atom_t UTF8_STRING = [[[[ewmhService atomService] cachedAtoms] objectForKey:[ewmhService UTF8_STRING]] unsignedIntValue];
    
    [ewmhService changePropertiesForWindow:clientWindow
                                  withMode:XCB_PROP_MODE_REPLACE
                              withProperty:[ewmhService EWMHWMName]
                                  withType: UTF8_STRING
                                withFormat:8
                            withDataLength:4
                                  withData:windowName];
    
    [connection flush];
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
                [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
                [titleBar setWindowTitle:@"Pova"];
                [connection flush];
                break;
                
            case XCB_MOTION_NOTIFY:
                NSLog(@"MOTION NOTIFY");
                [connection handleMotionNotify:(xcb_motion_notify_event_t *)e];
                [connection flush];
                break;
                
            case XCB_BUTTON_PRESS:
                NSLog(@"MBUTTON PRESS");
                [connection handleButtonPress:(xcb_button_press_event_t*)e];
                break;
                
            case XCB_MAP_NOTIFY:
                NSLog(@"MAP NOTIFY");
                break;
                
                
            default:
                break;
        }
        free(e);
    }
    
    NSUInteger dicionarySize = [[frame getChildren] count];
    NSUInteger knownChildren = 2;
    
    STAssertEquals(dicionarySize, knownChildren, @"Not equals");
    
    pause();
    
}

- (void) testHowXcbDrawsArcs
{
    xcb_connection_t  *c;
    xcb_screen_t      *screen;
    xcb_window_t      win;
    xcb_gcontext_t    foreground;
    uint32_t          mask;
    uint32_t          value[2];
    
    xcb_arc_t arcs[] =
    {
        {10, 100, 60, 40, 0, 360 << 6},
        {90, 100, 50, 40, 50, 360 << 6}
    };
    
    /* Open the connection to the X server and get the first screen */
    c = xcb_connect (NULL, NULL);
    screen = xcb_setup_roots_iterator (xcb_get_setup (c)).data;
    
    /* Create a black graphic context for drawing in the foreground */
    
    
    win = xcb_generate_id(c);
    
    mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    value[0] = screen->white_pixel;
    value[1] = XCB_EVENT_MASK_EXPOSURE;
    
    xcb_create_window(c,
                      XCB_COPY_FROM_PARENT,
                      win,
                      screen->root,
                      0, 0,
                      300, 300,
                      10,
                      XCB_WINDOW_CLASS_INPUT_OUTPUT,
                      screen->root_visual,
                      mask,
                      value);
    
    
    //win = screen->root;
    foreground = xcb_generate_id (c);
    mask = XCB_GC_FOREGROUND | XCB_GC_GRAPHICS_EXPOSURES;
    value[0] = screen->black_pixel;
    value[1] = 0;
    
    xcb_create_gc (c, foreground, win, mask, value);
    
    
    xcb_map_window(c, win);
    
    xcb_flush(c);
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event (c))) {
        switch (e->response_type & ~0x80) {
            case XCB_EXPOSE:
            {
                
                xcb_poly_arc (c, win, foreground, 2, arcs);
                xcb_flush (c);
                
                break;
            }
            default: {
                
                break;
            }
        }
        
        free (e);
    }
    
    pause();
}


- (void) testHowCairoDrawsArc
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBScreen *scr = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[scr screen]->root_visual];
    [visual setVisualTypeForScreen:scr];
    
    uint32_t values[2];
    values[0] = [scr screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE;
    
    XCBWindow *window = [self generateWindowWithConnection:connection andMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK andValues:values andVisual:visual];
    [connection mapWindow:window];
    
    
    cairo_surface_t *cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], 300, 300);
    
    cairo_t* cr = cairo_create(cairoSurface);
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
                //cairo_rectangle(cr, 0, 0, 300, 300);
                cairo_set_source_rgb(cr, 0.700, 0.427, 0.920);
                //cairo_move_to(cr, 0, 0);
                cairo_arc (cr, 128, 128, 20, 0  * (M_PI/180.0), 360 * (M_PI/180.0));
                cairo_fill(cr);
                cairo_surface_flush(cairoSurface);
                [connection flush];
                break;
                
            default:
                break;
        }
        free(e);
    }
    
    pause();
    
}

- (void) testHowCairoDrawsGradients
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t values[2];
    values[0] = [screen screen]->black_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE;
    
    XCBWindow *window = [self generateWindowWithConnection:connection andMask:XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK andValues:values andVisual:visual];
    
    [connection mapWindow:window];
    
    cairo_surface_t *cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], 300, 300);
    
    cairo_t* cr = cairo_create(cairoSurface);
    
    
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
                //cairo_rectangle(cr, 0, 0, 300, 300);
                cairo_set_source_rgb(cr, 0.700, 0.427, 0.920);
                //cairo_move_to(cr, 0, 0);
                
                cairo_pattern_t *r1;
                
                cairo_set_source_rgba(cr, 0, 0, 0, 1);
                cairo_set_line_width(cr, 12);
                
                /*r1 = cairo_pattern_create_radial(128, 128, 10, 128, 128, 20);
                 cairo_pattern_add_color_stop_rgba(r1, 0, 1, 1, 1, 1);
                 cairo_pattern_add_color_stop_rgba(r1, 1, 0.6, 0.6, 0.6, 1);
                 cairo_set_source(cr, r1);
                 cairo_fill(cr);*/
                
                /*cairo_pattern_t *r2;
                 
                 r2 = cairo_pattern_create_radial(128, 128, 10, 128, 128, 20);
                 cairo_pattern_add_color_stop_rgba(r2, 0, 0.8, 0.42, 0.92, 0.3);
                 cairo_pattern_add_color_stop_rgb(r2, 0.8, 0.7, 0.42, 0.920);
                 cairo_set_source(cr, r2);*/
                cairo_pattern_t *pat3 = cairo_pattern_create_linear(118, 118, 138, 138);
                
                cairo_pattern_add_color_stop_rgb(pat3, 0.9, 1, 1, 1);
                cairo_pattern_add_color_stop_rgb(pat3, 0.1, 0.7, 0.42, 0.92);
                cairo_pattern_add_color_stop_rgb(pat3, 0.9, 1, 1, 1);
                
                
                cairo_set_source(cr, pat3);
                
                cairo_arc (cr, 128, 128, 20, 0  * (M_PI/180.0), 360 * (M_PI/180.0));
                cairo_fill(cr);
                cairo_surface_flush(cairoSurface);
                [connection flush];
                break;
                
            default:
                break;
        }
        free(e);
    }
    
    pause();
    
}

- (XCBWindow*) generateWindowWithConnection:(XCBConnection*) aConnection andMask:(uint32_t) aMask andValues:(uint32_t*)someValues andVisual:(XCBVisual*) aVisual
{
    XCBScreen *scr = [[aConnection screens] objectAtIndex:0];
    
    XCBWindow *window = [aConnection createWindowWithDepth:XCB_COPY_FROM_PARENT
                                          withParentWindow:[scr rootWindow]
                                             withXPosition:1
                                             withYPosition:1
                                                 withWidth:300
                                                withHeight:300
                                          withBorrderWidth:10
                                              withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                              withVisualId:aVisual
                                             withValueMask:aMask
                                             withValueList:someValues];
    
    return window;
}

@end
