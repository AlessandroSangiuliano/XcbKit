//
// XCBAttributesReply.h
// XCBKit
//
// Created by slex on 23/10/20.
//

#import <Foundation/Foundation.h>
#import "XCBReply.h"
#import <xcb/xcb.h>

@interface XCBAttributesReply : XCBReply
{
}

@property (nonatomic) xcb_get_window_attributes_reply_t *attributesReply;
@property (nonatomic) uint8_t responeType;
@property (nonatomic) uint8_t backingStore;
@property (nonatomic) uint32_t length;
@property (nonatomic) xcb_visualid_t visualId;
@property (nonatomic) uint16_t classWindow;
@property (nonatomic) uint8_t bitGravity;
@property (nonatomic) uint8_t winGravity;
@property (nonatomic) uint32_t backingPlanes;
@property (nonatomic) uint32_t backingPixels;
@property (nonatomic) uint8_t saveUnder;
@property (nonatomic) uint8_t mapIsInstalled;
@property (nonatomic) uint8_t mapState;
@property (nonatomic) uint8_t overrideRedirect;
@property (nonatomic) xcb_colormap_t colorMap;
@property (nonatomic) uint32_t allEventMask;
@property (nonatomic) uint32_t yourEventMask;
@property (nonatomic) uint16_t doNotPropagateMask;

- (id) initWithAttributesReply:(xcb_get_window_attributes_reply_t*)aReply;

@end