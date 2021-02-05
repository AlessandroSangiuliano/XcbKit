//
// TitleBarSettings.m
// XCBKit
//
// Created by slex on 05/02/21.

#import "TitleBarSettings.h"

#define HEIGHT 22

@implementation TitleBarSettings

@synthesize heightDefined;

- (id) init
{
    return [self initWithHeight:-1];
}

- (id) initWithHeight:(uint16_t)aHeight
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unabl to init...");
        return nil;
    }

    defaultHeight = HEIGHT;

    if (aHeight != -1)
        height = aHeight;

    return self;
}

- (void) setHeight:(uint16_t)aHeight
{
    height = aHeight;
    heightDefined = YES;
}

- (uint16_t)height
{
    return height;
}

- (uint16_t) defaultHeight
{
    return defaultHeight;
}

@end