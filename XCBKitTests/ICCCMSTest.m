//
//  ICCCMSTest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 13/04/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <EWMHService.h>
#import <ICCCMService.h>
#import <XCBWindow.h>
#import "XCBConnection.h"


@interface ICCCMSTest : SenTestCase

@end

@implementation ICCCMSTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testGetProperty
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    ICCCMService* icccmService = [ICCCMService sharedInstanceWithConnection:connection];
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    
    const xcb_atom_t atom[1] = {[[icccmService atomService] atomFromCachedAtomsWithKey:[icccmService WMDeleteWindow]]};
    
    [icccmService changePropertiesForWindow:window
                                   withMode:XCB_PROP_MODE_REPLACE
                               withProperty:[icccmService WMProtocols] // questa è la property
                                   withType:XCB_ATOM_ATOM
                                 withFormat:32
                             withDataLength:1
                                   withData:atom]; //questo è il valore della proerty è come un key-value...
    
    xcb_atom_t* expected = (xcb_atom_t*)[icccmService getProperty:[icccmService WMProtocols]
                                                     propertyType:XCB_GET_PROPERTY_TYPE_ANY
                                                        forWindow:window
                                                           delete:NO];
    
    NSLog(@"Atom id %u", expected[0]);
    
    STAssertEquals(atom[0], expected[0], @"Must be equal");
    
}

- (void) testWindowHasProtocol
{
    XCBConnection* connection = [XCBConnection sharedConnection];
    ICCCMService* icccmService = [ICCCMService sharedInstanceWithConnection:connection];
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    [visual setVisualTypeForScreen:screen];
    
    uint32_t mask = XCB_CW_BACK_PIXEL | XCB_CW_EVENT_MASK;
    
    uint32_t values[2];
    values[0] = [screen screen]->white_pixel;
    values[1] = XCB_EVENT_MASK_EXPOSURE | XCB_EVENT_MASK_BUTTON_PRESS | XCB_EVENT_MASK_BUTTON_RELEASE |  XCB_EVENT_MASK_BUTTON_MOTION |
    XCB_EVENT_MASK_ENTER_WINDOW   | XCB_EVENT_MASK_LEAVE_WINDOW   | XCB_EVENT_MASK_KEY_PRESS;
    
    XCBCreateWindowTypeRequest* request = [[XCBCreateWindowTypeRequest alloc] initForWindowType:XCBWindowRequest];
    [request setWidth:300];
    [request setHeight:150];
    [request setVisual:visual];
    [request setXPosition:1];
    [request setYPosition:1];
    [request setXcbClass:XCB_WINDOW_CLASS_INPUT_OUTPUT];
    [request setDepth:[screen screen]->root_depth];
    [request setParentWindow:[screen rootWindow]];
    [request setBorderWidth:1];
    [request setValueMask:mask];
    [request setValueList:values];
    
    XCBWindowTypeResponse* reply = [connection createWindowForRequest:request registerWindow:YES];
    XCBWindow* window = [reply window];
    
    const xcb_atom_t atom[1] = {[[icccmService atomService] atomFromCachedAtomsWithKey:[icccmService WMDeleteWindow]]};
    
    [icccmService changePropertiesForWindow:window
                                   withMode:XCB_PROP_MODE_REPLACE
                               withProperty:[icccmService WMProtocols]
                                   withType:XCB_ATOM_ATOM
                                 withFormat:32
                             withDataLength:1
                                   withData:atom];
    
    BOOL hasProtocol = [icccmService hasProtocol:[icccmService WMDeleteWindow] forWindow:window];
    
    STAssertTrue(hasProtocol, @"");
}

@end
