//
//  XCBReply.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 26/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <xcb/xcb.h>
#import "enums/EXErrorMessages.h"

@interface XCBReply : NSObject

@property (nonatomic) BOOL isError;
@property (nonatomic) ErrorMessage message;
@property (nonatomic) void *reply;
@property (nonatomic) xcb_generic_error_t* error;

- (id) initWithReply:(void*)aReply;
- (id) initWithError:(xcb_generic_error_t*)anError;
- (void) description;

@end
