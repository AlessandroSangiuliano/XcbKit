//
// TitleBarSettings.h
// XCBKit
//
// Created by slex on 05/02/21.
//

#import <Foundation/Foundation.h>

@interface TitleBarSettings : NSObject
{
    uint16_t height;
    uint16_t defaultHeight;
}

@property (nonatomic, assign) BOOL heightDefined;

- (id) init;
- (id) initWithHeight:(uint16_t) aHeight;

/*** ACCESSORS ***/

- (void)setHeight:(uint16_t)aHeight;
- (uint16_t)height;
- (uint16_t) defaultHeight;

@end