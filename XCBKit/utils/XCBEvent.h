//
// Created by slex on 30/11/21.
//

#import <Foundation/Foundation.h>
#import <xcb/xcb.h>

@interface XCBEvent : NSObject

@property (assign, nonatomic) xcb_generic_event_t *event;

- (instancetype) initWithGenericXcbEvent:(xcb_generic_event_t *) anEvent;
- (xcb_map_notify_event_t *) asMapNotifyEvent;
- (xcb_property_notify_event_t*) asPropertyNotifyEvent;
- (xcb_expose_event_t *) asExposeEvent;
- (xcb_motion_notify_event_t *) asMotionNotifyEvent;
- (xcb_map_request_event_t *) asMapRequestEvent;

@end
