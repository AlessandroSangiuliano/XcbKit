//
// XCBShape.h
// XCBKit
//
// Created by slex on 26/03/21.
//

#import <Foundation/Foundation.h>
#import "XCBGeometryReply.h"
#include <xcb/shape.h>

@class XCBConnection;

@interface XCBShape : NSObject
{
    xcb_arc_t *windowArcs;
    xcb_arc_t *borderArcs;
}

@property (strong, nonatomic) XCBConnection* connection;
@property (nonatomic, assign, readonly) xcb_shape_query_extents_reply_t *shapeExtensionReply;
@property (nonatomic, assign) xcb_window_t winId;
@property (nonatomic, assign) xcb_pixmap_t borderPixmap;
@property (nonatomic, assign) xcb_pixmap_t windowPixmap;
@property (nonatomic, assign) xcb_gcontext_t black;
@property (nonatomic, assign) xcb_gcontext_t white;
@property (nonatomic, assign) int borderWidth;
@property (nonatomic, assign) int width;
@property (nonatomic, assign) int height;
@property (nonatomic, assign) int orWidth;
@property (nonatomic, assign) int orHeight;
@property (nonatomic, assign) int radius;


- (id) initWithConnection:(XCBConnection*)aConnection withWinId:(xcb_window_t)aWinId;
- (BOOL) checkSupported;
- (void) createPixmapsAndGCs;
- (void) createArcsWithRadius:(int)aRadius;
- (void) calculateDimensionsFromGeometries:(XCBGeometryReply*)aGeometryReply;

@end