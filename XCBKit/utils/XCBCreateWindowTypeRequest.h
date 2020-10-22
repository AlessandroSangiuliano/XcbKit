//
//  XCBCreateWindowTypeRequest.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 18/02/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "../XCBWindow.h"
#import "../XCBVisual.h"

typedef NS_ENUM(NSInteger, XCBWindowType)
{
    XCBFrameRequest = 0,
    XCBWindowRequest,
    XCBTitleBarRequest
};

@interface XCBCreateWindowTypeRequest : NSObject

@property (nonatomic) uint8_t depth;
@property (strong, nonatomic) XCBWindow* parentWindow;
@property (nonatomic) int16_t xPosition;
@property (nonatomic) int16_t yPosition;
@property (nonatomic) int16_t width;
@property (nonatomic) int16_t height;
@property (nonatomic) uint16_t borderWidth;
@property (nonatomic) uint16_t xcbClass;
@property (nonatomic, strong) XCBVisual* visual;
@property (nonatomic) uint32_t valueMask;
@property (nonatomic) const uint32_t * valueList;
@property (nonatomic) XCBWindowType windowType;
@property (strong, nonatomic) XCBWindow *clientWindow;


- (id) initForWindowType:(XCBWindowType)aWindowType;

@end
