//
//  XCBSize.h
//  XCBKit
//
//  Created by alex on 11/05/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XCBSize : NSObject
{
	uint16_t width;
	uint16_t height;
}

- (id) initWithWidht:(uint16_t) aWidth andHeight:(uint16_t) aHeight;
- (void) setWidth:(uint16_t)aWidth;
- (uint16_t) getWidth;
- (void) setHeight:(uint16_t) aHeight;
- (uint16_t) getHeight;
- (void) description;

@end
