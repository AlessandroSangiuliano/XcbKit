//
// Server.h
// XCBKit
//
// Created by slex on 22/11/21.
//

#import <Foundation/Foundation.h>

@protocol Server <NSObject>

@optional

- (NSMutableDictionary *) requestWindowsMap;
- (void) sendNotification:(NSNotification *)aNotification;

@end