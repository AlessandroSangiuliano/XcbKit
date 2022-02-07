//
//  XCBWindowTypeResponse.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 18/02/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XCBFrame;
@class XCBWindow;
@class XCBTitleBar;

@interface XCBWindowTypeResponse : NSObject

@property (nonatomic, strong) XCBWindow *window;
@property (nonatomic, strong) XCBTitleBar *titleBar;
@property (nonatomic, strong) XCBFrame *frame;

- (id) initWithXCBWindow:(XCBWindow*)aWindow;
- (id) initWithXCBFrame:(XCBFrame*)aFrame;
- (id) initWithXCBTitleBar:(XCBTitleBar*)aTitlebar;

@end
