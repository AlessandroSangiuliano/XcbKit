//
// TitleBarSettingsService.h
// XCBKit
//
// Created by slex on 05/02/21.
//

#import <Foundation/Foundation.h>

@interface TitleBarSettingsService : NSObject
{
    uint16_t height;
    uint16_t defaultHeight;
}

@property (nonatomic, assign) BOOL heightDefined;

- (id) init;
+ (id) sharedInstance;

/*** ACCESSORS ***/

- (void)setHeight:(uint16_t)aHeight;
- (uint16_t)height;
- (uint16_t) defaultHeight;

@end