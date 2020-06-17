//
//  XCBWindowTests.m
//  XCBKit
//
//  Created by alex on 28/04/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBWindowTests.h"
#import "XCBWindow.h"
#import "XCBConnection.h"
#import "XCBCreateWindowTypeRequest.h"
#import "XCBWindowTypeResponse.h"
#import "XCBVisual.h"
#import "CairoDrawer.h"

@implementation XCBWindowTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void) testWindowIdStringValue
{
	xcb_window_t window = 1;
	XCBWindow * aWindow = [[XCBWindow alloc] init];
	[aWindow setWindow:window];
	
	NSString *stringId = [aWindow windowIdStringValue];
	NSString *testCompare = [NSString stringWithFormat:@"%u", 1];
	STAssertEquals(stringId, testCompare, @"Expected id: 1");
}

- (void) testSetBorderWidth
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];

    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:XCB_NONE];
    [request setValueList:NULL];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    [connection mapWindow:window];
    [connection flush];
    
    [window setWindowBorderWidth:10];
    [connection flush];
    
    pause();
}

- (void) testTakeScreenshot
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    
    CairoDrawer* drawer = [[CairoDrawer alloc] initWithConnection:connection window:window visual:visual];
    
    request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:100];
    [request setYPosition:100];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];

    reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window2 = [reply window];

    

    [connection mapWindow:window];
    [connection mapWindow:window2];
    [connection flush];
    
    //[drawer takeScreenShot];
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
            {
                NSLog(@"Expose");
                [drawer drawText:@"AISSALARAISS" withColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1]];
                [drawer makePreviewImage];
                [drawer setWindow:window2];
                [drawer setPreviewImage];
                [connection flush];
                break;
            }
            case XCB_MOTION_NOTIFY:
                [connection handleMotionNotify:(xcb_motion_notify_event_t *)e];
                [connection flush];
                break;
                
            case XCB_BUTTON_PRESS:
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

    pause();
    
}

- (void) testHowTakeScreenshotXCBorCairo
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    
    CairoDrawer* drawer = [[CairoDrawer alloc] initWithConnection:connection window:window visual:visual];
    
    request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:100];
    [request setYPosition:100];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window2 = [reply window];
    
    [window description];
    
    
    
    [connection mapWindow:window];
    //[connection mapWindow:window2];
    [connection flush];
    
    //[drawer takeScreenShot];
    
    xcb_generic_event_t *e;
    
    while ((e = xcb_wait_for_event([connection connection])))
    {
        switch (e->response_type & ~0x80)
        {
            case XCB_EXPOSE:
            {
                NSLog(@"Expose");
                [drawer drawText:@"AISSALARAISS" withColor:[NSColor colorWithCalibratedRed:0.0 green:0.0 blue:0.0 alpha:1]];
                [connection flush];
                break;
            }
            case XCB_MOTION_NOTIFY:
                [connection handleMotionNotify:(xcb_motion_notify_event_t *)e];
                [connection flush];
                break;
                
            case XCB_BUTTON_PRESS:
                //[self withCairoStride:window];
                [self cairoScreenForWindow:window andConnection:connection andVisual:visual];
                break;
                
            case XCB_MAP_NOTIFY:
                NSLog(@"MAP NOTIFY");
                [connection flush];
                break;
            default:
                break;
        }
        free(e);
    }
    
    pause();

}

- (void) cairoScreenForWindow:(XCBWindow*)aWindow andConnection:(XCBConnection*)aConnection andVisual:(XCBVisual*)aVisual
{
    cairo_surface_t *surface = cairo_xcb_surface_create([aConnection connection],
                                                        [aWindow window],
                                                        [aVisual visualType],
                                                        [aWindow windowRect].size.width,
                                                        [aWindow windowRect].size.height);
    
        
    cairo_t* cr = cairo_create(surface);
    cairo_scale(cr, 0.5, 0.5);
    cairo_set_source_surface(cr, surface, 0, 0);
    cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_paint(cr);
    cairo_surface_write_to_png(surface, "/tmp/gigio.png");
    
}

/*- (void) makeScreenshotForWindow:(XCBWindow*)aWindow andConnection:(XCBConnection*)aConnection
{
    [aWindow createPixmap];
    xcb_pixmap_t pixmap = [aWindow pixmap];
    
    xcb_get_image_cookie_t cookie = xcb_get_image([aConnection connection],
                                                  XCB_IMAGE_FORMAT_Z_PIXMAP,
                                                  [aWindow window],
                                                  [[[aWindow windowRect] position] getX],
                                                  [[[aWindow windowRect] position] getY],
                                                  [[[aWindow windowRect] size] getWidth],
                                                  [[[aWindow windowRect] size] getHeight],
                                                  (uint32_t)(~0UL));
    
    xcb_generic_error_t *err = NULL;
    xcb_get_image_reply_t* reply = xcb_get_image_reply([aConnection connection],
                                                        cookie,
                                                        &err);
    
    if (!reply)
    {
        NSLog(@"Error %d", err->error_code);
    }
    
    int length = xcb_get_image_data_length(reply);
    
    uint8_t *pixels = xcb_get_image_data(reply);
    
    
    for (int i = 0; i < lenght; i++)
    {
        int r = (pixels[i] >> 22) & 0xff;
        int g = (pixels[i] >> 12) & 0xff;
        int b = (pixels[i] >> 2) & 0xff;
        
        pixels[i] = rgba(r, g, b, 0xff);
    }
    
    
    FILE *fp = fopen("/tmp/pova.png", "w+");
    fwrite(pixels, length, 1, fp );
    fclose(fp);
    
}

- (void) withCairoStride:(XCBWindow*)aWindow
{
    int stride;
    unsigned char *data;
    cairo_surface_t *surface;
    
    stride = cairo_format_stride_for_width(CAIRO_FORMAT_RGB24, [[[aWindow windowRect] size] getWidth]);
    data = malloc(stride * [[[aWindow windowRect] size] getHeight]);
    surface = cairo_image_surface_create_for_data(data,
                                                  CAIRO_FORMAT_RGB24,
                                                  [[[aWindow windowRect] size] getWidth],
                                                  [[[aWindow windowRect] size] getHeight],
                                                  stride);
    
    cairo_t *cr = cairo_create(surface);
    cairo_surface_write_to_png(surface, "/tmp/pova.png");
    
    
}

unsigned int rgba(int r, int g, int b, int a)
{
    return ((a & 0xffu) << 24) | ((r & 0xffu) << 16) | ((g & 0xffu) << 8) | (b & 0xffu);
}*/

@end
