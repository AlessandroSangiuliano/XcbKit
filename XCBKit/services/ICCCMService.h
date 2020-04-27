//
//  Pova.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 12/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "EWMHService.h"

@interface ICCCMService : EWMHService

@property (strong, nonatomic) NSArray* atomsArray;
@property (strong, nonatomic) NSString* WMDeleteWindow;
@property (strong, nonatomic) NSString* WMProtocols;

+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection;

- (id) initWithConnection:(XCBConnection*) aConnection;
- (BOOL)hasProtocol:(NSString*)protocol forWindow:(XCBWindow*)window;

@end
