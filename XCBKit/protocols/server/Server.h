//
// Server.h
// XCBKit
//
// Created by slex on 22/11/21.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import "enums/ERequests.h"

@protocol Server <NSObject>

@property (nonatomic, strong) NSString *serverName;

@optional

- (id) handleRequestFor:(Request)aRequest;
- (void) handleNotification:(NSNotification *)aNotification;

@end