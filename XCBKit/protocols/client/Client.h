//
// Client.h
// XCBKit
//
// Created by slex on 23/11/21.
//

#import <Foundation/Foundation.h>

@protocol Client <NSObject>

@optional

- (void) handleNotification:(NSNotification *) aNotification;

@end