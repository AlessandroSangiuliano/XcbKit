//
//  XCBShape.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 15/06/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <xcb/xcb.h>

typedef struct _XCBPoint
{
    int16_t x;
    int16_t y;
    
} XCBPoint;

typedef struct _XCBSize
{
    uint16_t width;
    uint16_t height;
    
} XCBSize;

typedef struct _XCBRect
{
    XCBPoint position;
    XCBSize size;
} XCBRect;

typedef struct _XCBColor
{
    double redComponent;
    double greenComponent;
    double blueComponent;
    double alphaComponent;
} XCBColor;

static const XCBRect XCBInvalidRect = {{0xffff, 0xffff}, {0xffff, 0xffff}};

/*** Utility functions ***/

static inline XCBColor XCBMakeColor(double redComponent, double greenComponent, double blueComponent, double alphaComponent)
{
    XCBColor color = {redComponent, greenComponent, blueComponent, alphaComponent};
    return color;
}

static inline XCBPoint XCBMakePoint(int16_t x, int16_t y)
{
    XCBPoint point = {x, y};
    return point;
}

static inline XCBSize XCBMakeSize(uint16_t width, uint16_t height)
{
    XCBSize size = {width, height};
    return size;
}

static inline XCBRect XCBMakeRect(XCBPoint point, XCBSize size)
{
    XCBRect rect = {point, size};
    return rect;
}

static inline xcb_rectangle_t FnFromXCBRectToXcbRectangle(XCBRect rect)
{
    xcb_rectangle_t r = {rect.position.x, rect.position.y, rect.size.width, rect.size.height};
    return r;
}

static inline XCBRect FnFromXcbRectangleToXCBRect(xcb_rectangle_t rect)
{
    XCBRect r = {{rect.x, rect.y,}, {rect.width, rect.height}};
    return r;
}

static inline BOOL FnCheckXCBRectIsValid(XCBRect rect)
{
    BOOL valid = YES;
    
    if (rect.position.x == XCBInvalidRect.position.x &&
        rect.position.y == XCBInvalidRect.position.y &&
        rect.size.width == XCBInvalidRect.size.width &&
        rect.size.height == XCBInvalidRect.size.height)
        
        valid = NO;

    return valid;
}

static inline NSString* FnFromXCBRectToString(XCBRect rect)
{
    return [NSString stringWithFormat:@"Position: (x: %hd, y: %hd), Size: (width: %hd, height: %hd)",
            rect.position.x, rect.position.y, rect.size.width, rect.size.height];
}

@interface XCBShape : NSObject



@end
