//
// EIcccm.h
// XCBKit
//
// Created by slex on 08/12/20.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, Icccm)
{
    ICCCMInputHint = 1,
    ICCCMStateHint = 2,
    ICCCMIconPixmapHint = 4,
    ICCCMIconWindowHint = 8,
    ICCCMIconPositionHint = 16,
    ICCCMIconMaskHint = 32,
    ICCCMWindowGroupHint = 64,
    ICCCMUrgencyHint = 256,
    ICCCMFlags,
    ICCCMIconPositionHintX,
    ICCCMIconPositionHintY
};