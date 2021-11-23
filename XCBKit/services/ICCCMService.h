//
//  Pova.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 12/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "EWMHService.h"
#include <xcb/xcb_icccm.h>

@interface ICCCMService : EWMHService

@property (strong, nonatomic) NSArray* atomsArray;
@property (strong, nonatomic) NSString* WMDeleteWindow;
@property (strong, nonatomic) NSString* WMTakeFocus;
@property (strong, nonatomic) NSString* WMProtocols;
@property (strong, nonatomic) NSString* WMName;
@property (strong, nonatomic) NSString* WMNormalHints;
@property (strong, nonatomic) NSString* WMSizeHints;
@property (strong, nonatomic) NSString* WMState;
@property (strong, nonatomic) NSString* WMHints;
@property (strong, nonatomic) NSString* WMChangeState;
@property (strong, nonatomic) NSString* WMClass;

+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection;

- (id) initWithConnection:(XCBConnection*) aConnection;
- (BOOL)hasProtocol:(NSString*)protocol forWindow:(XCBWindow*)window;
- (xcb_size_hints_t*) wmNormalHintsForWindow:(XCBWindow*)aWindow;
- (void)updateWMNormalHints:(xcb_size_hints_t*)sizeHints forWindow:(XCBWindow*)aWindow;
- (NSString*) getWmNameForWindow:(XCBWindow*)aWindow;
- (xcb_icccm_wm_hints_t) wmHintsFromWindow:(XCBWindow*)aWindow;
- (void) setWMStateForWindow:(XCBWindow*)aWindow state:(WindowState)state;
- (WindowState) wmStateFromWindow:(XCBWindow*)aWindow;
- (void) wmClassForWindow:(XCBWindow*)aWindow;


@end
