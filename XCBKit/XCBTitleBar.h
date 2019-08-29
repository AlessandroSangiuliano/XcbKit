//
//  XCBTitleBar.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 06/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBWindow.h"
#import "XCBFrame.h"
#import "XCBSize.h"


@interface XCBTitleBar : XCBWindow

    @property(strong,nonatomic) XCBWindow *hideWindowButton;
    @property(strong, nonatomic) XCBWindow *minizeWindowButton;
    @property(strong,nonatomic) XCBWindow *maximizeWindowButton;

- (id) initWithFrame:(XCBFrame*) aFrame withConnection:(XCBConnection*) aConnection;
@end
