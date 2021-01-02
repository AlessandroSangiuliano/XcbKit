//
// EMousePosition.h
// XCBKit
//
// Created by slex on 01/01/21.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, MousePosition)
{
    RightBorder,
    LeftBorder,
    TopBorder,
    BottomBorder,
    BottomRightCorner,
    Error,
    None
};