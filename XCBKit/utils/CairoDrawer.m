//
//  CairoDrawer.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 02/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "CairoDrawer.h"
#import "../XCBTitleBar.h"
#import "../services/TitleBarSettingsService.h"
#import <xcb/xcb_aux.h>
#import "../functions/Comparators.h"

#ifndef M_PI
#define M_PI        3.14159265358979323846264338327950288
#endif

static cairo_user_data_key_t data_key;

static inline void free_callback(void *data)
{
    free(data);
}

@implementation CairoDrawer

@synthesize cairoSurface;
@synthesize cr;
@synthesize connection;
@synthesize window;
@synthesize visual;
@synthesize height;
@synthesize width;
@synthesize alreadyScaled;

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
    [self setWindow:aWindow];
    visual = aVisual;
    
    height = (CGFloat)[aWindow windowRect].size.height;
    width = (CGFloat)[aWindow windowRect].size.width;
    
    XCBScreen *screen = [window onScreen];
    
    if (visual != nil)
        [visual setVisualTypeForScreen:screen];
    else if (window != nil)
    {
        xcb_visualid_t visualid = [[window attributes] visualId];
        visual = [[XCBVisual alloc] initWithVisualId:visualid withVisualType:xcb_aux_find_visual_by_id([screen screen], visualid)];
    }
    
    screen = nil;
    alreadyScaled = NO;
    
    return self;
}

- (id) initWithConnection:(XCBConnection *)aConnection window:(XCBWindow*) aWindow
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init");
        return nil;
    }

    connection = aConnection;
    [self setWindow:aWindow];

    visual = [window visual];

    height = (CGFloat)[aWindow windowRect].size.height;
    width = (CGFloat)[aWindow windowRect].size.width;
    alreadyScaled = NO;

    return self;
}

- (void) drawTitleBarButtonWithColor:(XCBColor)buttonColor withStopColor:(XCBColor)stopColor
{
    XCBTitleBar *titleBar = (XCBTitleBar*)[window parentWindow];

    if (CmXCBColorAreEquals(buttonColor, [titleBar titleBarDownColor]))
        cairoSurface = cairo_xcb_surface_create([connection connection], [window dPixmap], [visual visualType], width, height);

    if (!CmXCBColorAreEquals(buttonColor, [titleBar titleBarDownColor]))
        cairoSurface = cairo_xcb_surface_create([connection connection], [window pixmap], [visual visualType], width, height);

    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, buttonColor.redComponent, buttonColor.greenComponent, buttonColor.blueComponent);
    
    CGFloat startXPosition = 2;
    CGFloat endXPosition = 2;
    CGFloat startYPosition = 2; /// it was 1 previously, just try it for a bit!
    CGFloat endYPosition = height + 2;
    
    CGFloat stopGradientOffset = 0.9;
    CGFloat colorGradientOffset = 0.1;
    
    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, buttonColor.redComponent, buttonColor.greenComponent, buttonColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    
    cairo_set_source(cr, pat);
    
    CGFloat xPosition = (CGFloat) width / 2;
    CGFloat yPosition = (CGFloat) height / 2;
    CGFloat radius = (CGFloat) height / 2.0 + 1; /* 1 solves a bad looking problem about circular window */
    
    cairo_arc (cr, xPosition, yPosition, radius, 0  * (M_PI / 180.0), 360 * (M_PI / 180.0));
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);

    cairo_set_line_width (cr, 0.2);

    cairo_arc (cr, xPosition, yPosition, radius, 0  * (M_PI / 180.0), 360 * (M_PI / 180.0));
    
    cairo_set_source_rgb(cr, buttonColor.redComponent, buttonColor.greenComponent, buttonColor.blueComponent);
    cairo_stroke(cr);
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);

    titleBar = nil;
}

- (void) drawTitleBarWithColor:(XCBColor)titleColor andStopColor:(XCBColor)stopColor
{
    XCBTitleBar *titleBar = (XCBTitleBar*)window;

    if (CmXCBColorAreEquals(titleColor, [titleBar titleBarUpColor]))
        cairoSurface = cairo_xcb_surface_create([connection connection], [window pixmap], [visual visualType], width, height-1);

    if (CmXCBColorAreEquals(titleColor, [titleBar titleBarDownColor]))
        cairoSurface = cairo_xcb_surface_create([connection connection], [window dPixmap], [visual visualType], width, height-1);

    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, titleColor.redComponent, titleColor.greenComponent, titleColor.blueComponent);
    
    CGFloat startXPosition = 0;
    CGFloat endXPosition = 0;
    CGFloat startYPosition = height;
    CGFloat endYPosition = [window windowRect].position.y;
    
    CGFloat stopGradientOffset = 0.99;
    CGFloat colorGradientOffset = 0.2;
    
    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, titleColor.redComponent, titleColor.greenComponent, titleColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    
    
    cairo_set_source(cr, pat);
    
    cairo_rectangle(cr, [window windowRect].position.x, [window windowRect].position.y, width, height-1);
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);

    titleBar = nil;
    
}

- (void) drawWindowWithColor:(XCBColor)aColor andStopColor:(XCBColor)stopColor
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, aColor.redComponent, aColor.greenComponent, aColor.blueComponent);
    
    CGFloat startXPosition = 0;
    CGFloat endXPosition = 0;
    CGFloat startYPosition = height;
    CGFloat endYPosition = -3;
    
    CGFloat stopGradientOffset = 0.99;
    CGFloat colorGradientOffset = 0.2;
    
    cairo_pattern_t *pat = cairo_pattern_create_linear(startXPosition, startYPosition, endXPosition, endYPosition);
    
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, colorGradientOffset, aColor.redComponent, aColor.greenComponent, aColor.blueComponent);
    cairo_pattern_add_color_stop_rgb(pat, stopGradientOffset, stopColor.redComponent, stopColor.greenComponent, stopColor.blueComponent);
    
    
    cairo_set_source(cr, pat);
    
    cairo_rectangle(cr, 0, 0, width, height);
    cairo_fill(cr);
    
    cairo_surface_flush(cairoSurface);
    
    cairo_pattern_destroy(pat);
    
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
    
}

- (void) drawContent
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window pixmap], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);

    cairo_surface_write_to_png(cairoSurface, "/tmp/Pixmap.png");
    
    cairo_surface_flush(cairoSurface);
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);

    cairoSurface = cairo_xcb_surface_create([connection connection], [window dPixmap], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);

    cairo_surface_write_to_png(cairoSurface, "/tmp/dPixmap.png");

    cairo_surface_flush(cairoSurface);
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
}

- (void) drawIconFromSurface:(cairo_surface_t*)aSurface
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    //cairoSurface = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
    cr = cairo_create(cairoSurface);
    /*cairo_surface_t* similar = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, width, height);
    cairo_t* aux = cairo_create(similar);
    cairo_set_source_surface(aux, aSurface, 0, 0);
    cairo_set_operator(aux, CAIRO_OPERATOR_SOURCE);
    cairo_paint(aux);*/
    cairo_surface_write_to_png(aSurface, "/tmp/Pova.png");

    /*cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
    cairo_set_source_surface(cr, similar,0,0);*/
    cairo_paint(cr);
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
}

- (void) drawText:(NSString *)aText withColor:(XCBColor)aColor
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    cr = cairo_create(cairoSurface);
    
    cairo_set_source_rgb(cr, aColor.redComponent, aColor.greenComponent, aColor.blueComponent);
    
    cairo_select_font_face(cr, "Serif", CAIRO_FONT_SLANT_NORMAL, CAIRO_FONT_WEIGHT_NORMAL);
    
    cairo_set_font_size (cr, 11);
    
    cairo_set_source_rgb (cr, aColor.redComponent, aColor.greenComponent, aColor.blueComponent);
    
    cairo_text_extents_t  extents;
    const char* utfString = [aText UTF8String];
    cairo_text_extents(cr, utfString, &extents);

    CGFloat halfLength = extents.width / 2;
    
    CGFloat textPositionX = (CGFloat) [window windowRect].size.width / 2;
    CGFloat textPositionY = (CGFloat) [window windowRect].size.height / 2 + 2;
    
    cairo_move_to(cr, textPositionX - halfLength, textPositionY);
    
    cairo_show_text(cr, utfString);
    
    cairo_surface_flush(cairoSurface);
    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
}

- (void) makePreviewImage
{
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], width, height);
    /*if ([[window parentWindow] isAbove] == NO)
        cairoSurface = cairo_xcb_surface_create([connection connection], [window pixmap], [visual visualType], size.width, size.height);
    else
        cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], size.width, size.height);*/

    cr = cairo_create(cairoSurface);
    cairo_set_source_surface(cr, cairoSurface, 0,0);
    cairo_paint(cr);

    cairo_surface_write_to_png(cairoSurface, "/tmp/Preview.png");

    cairo_surface_destroy(cairoSurface);
    cairo_destroy(cr);
}

- (void) putImage:(NSString*)aPath forDPixmap:(BOOL)aValue
{
    TitleBarSettingsService *settingsService = [TitleBarSettingsService sharedInstance];
    XCBSize size = [window windowRect].size;
    XCBPoint position;

    if (!aValue)
        cairoSurface = cairo_xcb_surface_create([connection connection], [window pixmap], [visual visualType], size.width, size.height);
    else
        cairoSurface = cairo_xcb_surface_create([connection connection], [window dPixmap], [visual visualType], size.width, size.height);

    cr = cairo_create(cairoSurface);

    cairo_surface_t* imageSurface = cairo_image_surface_create_from_png([aPath cString]);
    cairo_surface_t* similar = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, size.width, size.height);
    cairo_t* similarCtx = cairo_create(similar);

    cairo_set_source_surface(similarCtx, imageSurface, 0, 0);
    cairo_set_operator(similarCtx, CAIRO_OPERATOR_SOURCE);
    cairo_paint(similarCtx);

    if ([window isCloseButton])
        position = [settingsService closePosition];
    else if ([window isMaximizeButton])
        position = [settingsService maximizePosition];
    else if ([window isMinimizeButton])
        position = [settingsService minimizePosition];
    /*** TODO: else the window is not one of the 3 title button... add a geneneric settings for windows? or something else ***/

    cairo_set_source_surface(cr, similar, position.x, position.y);
    cairo_paint(cr);

    cairo_surface_destroy(cairoSurface);
    cairo_surface_destroy(imageSurface);
    cairo_surface_destroy(similar);
    cairo_destroy(cr);
    cairo_destroy(similarCtx);
    settingsService = nil;

    return;
}

- (void)setPreviewImage
{
    XCBSize size = [window windowRect].size;
    cairoSurface = cairo_xcb_surface_create([connection connection], [window window], [visual visualType], size.width, size.height);
    cr = cairo_create(cairoSurface);
    
    /* CHECK IF THE COMPOSITORE IS ACTIVE, IF TRUE I CAN SET THE TRANSPARENCY
     cairo_set_source_rgba(cr, 1, 1, 1, 0.0);
     cairo_set_operator(cr, CAIRO_OPERATOR_SOURCE);
     cairo_paint(cr);*/
    
    cairo_surface_t* imageSurface = cairo_image_surface_create_from_png("/tmp/Preview.png");
    cairo_surface_t* similar = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, size.width, size.height);
    cairo_t* aux = cairo_create(similar);
    
    double scalingFactorW = 50.0 /(double) cairo_image_surface_get_width(imageSurface);
    double scalingFactorH = 50.0 /(double) cairo_image_surface_get_height(imageSurface);
    
    cairo_scale(aux, scalingFactorW, scalingFactorH);
    cairo_set_source_surface(aux, imageSurface, 0, 0);
    cairo_set_operator(aux, CAIRO_OPERATOR_SOURCE);
    cairo_paint(aux);
    
    cairo_set_source_surface(cr, similar, 0, 0);
    cairo_paint(cr);

    //cairo_surface_write_to_png(similar, "/tmp/Scaled.png");
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError* error;
    //[fileManager removeItemAtPath:@"/tmp/Scaled.png" error:&error];
    [fileManager removeItemAtPath:@"/tmp/Preview.png" error:&error];
    
    cairo_paint(cr);
    
    cairo_surface_destroy(cairoSurface);
    cairo_surface_destroy(imageSurface);
    cairo_surface_destroy(similar);
    cairo_destroy(cr);
    cairo_destroy(aux);
    
    error = nil;
    fileManager = nil;
}

- (void) saveContext
{
    cairo_save(cr);
}

- (void) restoreContext
{
    cairo_restore(cr);
}

-(cairo_surface_t*)drawContentFromData:(uint32_t*)data withWidht:(int)aWidth andHeight:(int)aHeight
{
    width = aWidth;
    height = aHeight;
    unsigned long int len = aWidth * aHeight;
    unsigned long int i;
    uint32_t *buffer = (uint32_t*) malloc(sizeof(uint32_t) * len);

    for(i = 0; i < len; i++)
    {
        uint8_t a = (data[i] >> 24) & 0xff;
        double alpha = a / 255.0;
        uint8_t r = ((data[i] >> 16) & 0xff) * alpha;
        uint8_t g = ((data[i] >>  8) & 0xff) * alpha;
        uint8_t b = ((data[i] >>  0) & 0xff) * alpha;
        buffer[i] = (a << 24) | (r << 16) | (g << 8) | b;
    }

    cairoSurface = cairo_image_surface_create_for_data((unsigned char *) buffer,
                                                CAIRO_FORMAT_ARGB32,
                                                aWidth,
                                                aHeight,
                                                aWidth*4);

    cairo_surface_set_user_data(cairoSurface, &data_key, buffer, &free_callback);

    return cairoSurface;

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
