//
// TitleBarSettingsService.h
// XCBKit
//
// Created by slex on 05/02/21.
//

#import <Foundation/Foundation.h>
#import "../utils/XCBShape.h"

@interface TitleBarSettingsService : NSObject
{
    uint16_t height;
    uint16_t defaultHeight;
}

@property (nonatomic, assign) BOOL heightDefined;
@property (nonatomic, assign) XCBPoint closePosition;
@property (nonatomic, assign) XCBPoint minimizePosition;
@property (nonatomic, assign) XCBPoint maximizePosition;
@property (strong, nonatomic) NSString *closePathName;
@property (strong, nonatomic) NSString *minimizePathName;
@property (strong, nonatomic) NSString *maximizePathName;

- (id) init;
+ (id) sharedInstance;

/*** ACCESSORS ***/

- (void)setHeight:(uint16_t)aHeight;
- (uint16_t)height;
- (uint16_t) defaultHeight;

@end