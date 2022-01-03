//
// Created by slex on 30/11/21.
//

#import "XCBEvent.h"

@implementation XCBEvent

@synthesize event;

- (instancetype)initWithGenericXcbEvent:(xcb_generic_event_t*)anEvent
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }

    event = anEvent;

    return self;

}

- (xcb_map_notify_event_t *) asMapNotifyEvent
{
    return (xcb_map_notify_event_t *) event;
}

- (xcb_property_notify_event_t*)asPropertyNotifyEvent
{
    return (xcb_property_notify_event_t*) event;
}

- (xcb_expose_event_t *)asExposeEvent
{
    return (xcb_expose_event_t *) event;
}

- (xcb_motion_notify_event_t *)asMotionNotifyEvent
{
   return (xcb_motion_notify_event_t *) event;
}

- (xcb_map_request_event_t *)asMapRequestEvent
{
    return (xcb_map_request_event_t *) event;
}

- (void)dealloc
{
    if (event)
        free(event);
}
@end