//
// XCBArrtibutesReply.m
// XCBKit
//
// Created by slex on 23/10/20.

#import "XCBAttributesReply.h"

@implementation XCBAttributesReply

@synthesize attributesReply;
@synthesize responeType;
@synthesize backingStore;
@synthesize length;
@synthesize visualId;
@synthesize classWindow;
@synthesize bitGravity;
@synthesize winGravity;
@synthesize backingPlanes;
@synthesize backingPixels;
@synthesize saveUnder;
@synthesize mapIsInstalled;
@synthesize mapState;
@synthesize overrideRedirect;
@synthesize colorMap;
@synthesize allEventMask;
@synthesize yourEventMask;
@synthesize doNotPropagateMask;

- (id) initWithAttributesReply:(xcb_get_window_attributes_reply_t*)aReply
{
    self = [super initWithReply:aReply];

    if (self == nil)
        return nil;

    attributesReply = aReply;
    responeType = aReply->response_type;
    backingStore = aReply->backing_store;
    length = aReply->length;
    visualId = aReply->visual;
    classWindow = aReply->_class;
    bitGravity = aReply->bit_gravity;
    winGravity = aReply->win_gravity;
    backingStore = aReply->backing_store;
    backingPixels = aReply->backing_pixel;
    saveUnder = aReply->save_under;
    mapIsInstalled = aReply->map_is_installed;
    mapState = aReply->map_state;
    overrideRedirect = aReply->override_redirect;
    colorMap = aReply->colormap;
    allEventMask = aReply->all_event_masks;
    yourEventMask = aReply->your_event_mask;
    doNotPropagateMask = aReply->do_not_propagate_mask;

    return self;
}

- (void) dealloc
{
    /*responeType = NULL;
    backingStore = NULL;
    length = NULL;
    visualId = NULL;
    classWindow = NULL;
    bitGravity = NULL;
    winGravity = NULL;
    backingPlanes = NULL;
    backingPixels = NULL;
    saveUnder = NULL;
    mapIsInstalled = NULL;
    mapState = NULL;
    overrideRedirect = NULL;
    colorMap = NULL;
    allEventMask = NULL;
    yourEventMask = NULL;
    doNotPropagateMask = NULL;*/
}
@end