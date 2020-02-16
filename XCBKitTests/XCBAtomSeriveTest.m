//
//  XCBAtomSeriveTest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 08/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "XCBAtomService.h"
#import "XCBConnection.h"
#import "EWMHService.h"
#import "XCBScreen.h"

@interface XCBAtomSeriveTest : SenTestCase

@end

@implementation XCBAtomSeriveTest

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

- (void) testCacheAtom
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    
    NSString *wmName = @"_NET_WM_NAME";
    NSString *supported = @"_NET_SUPPORTED";
    
    [atomService cacheAtom:wmName];
    [atomService cacheAtom:supported];
    
    NSDictionary *cachedAtoms = [atomService cachedAtoms];
    
    NSNumber *atomValueForName = [cachedAtoms objectForKey:wmName];
    xcb_atom_t atomWmName = [atomValueForName unsignedIntValue];
    
    NSNumber *atomForSupported =  [cachedAtoms objectForKey:supported];
    xcb_atom_t atomSupported = [atomForSupported unsignedIntValue];
    
    NSLog(@"Atom value for name: %u", atomWmName);
    NSLog(@"Atom value for supported: %u", atomSupported);
    
    STAssertEquals(atomWmName, 256u, @"Expected 256");
    STAssertEquals(atomSupported, 294u, @"Expected 294");
}

- (void) testCacheAtoms
{
    NSString* atoms[] = {@"_NET_WM_NAME", @"_NET_SUPPORTED"};
    
    NSArray *atomsArray = [[NSArray alloc] initWithObjects:atoms count:sizeof(atoms) / sizeof(NSString*)];
    
    XCBConnection *connection = [XCBConnection sharedConnection];
    
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    
    [atomService cacheAtoms:atomsArray];
    
    NSDictionary *cachedAtoms = [atomService cachedAtoms];
    
    STAssertEquals([[cachedAtoms objectForKey:atoms[0]] unsignedIntValue], 256u, @"Expected 256");
    STAssertEquals([[cachedAtoms objectForKey:atoms[1]] unsignedIntValue], 294u, @"Expected 294");
}

- (void) testAtomFromCachedAtomsWithKey
{
    NSString *netSupported = @"_NET_SUPPORTED";
    
    XCBConnection *connection = [XCBConnection sharedConnection];
    
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    
    [atomService cacheAtom:netSupported];
    
    NSDictionary *cachedAtoms = [atomService cachedAtoms];
    
    xcb_atom_t atomSupported = [atomService atomFromCachedAtomsWithKey:netSupported];
    
    STAssertEquals([[cachedAtoms objectForKey:netSupported] unsignedIntValue], atomSupported, @"MUST be equal");
    
}

- (void) testCacheRootandWmWindowProperties
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    EWMHService *ewmhService = [EWMHService sharedInstanceWithConnection:connection];
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    
    XCBWindow *rootWindow = [[XCBWindow alloc] initWithXCBWindow:[screen screen]->root];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen]->root_visual];
    
    XCBWindow *wmWindow = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
                                           withParentWindow:rootWindow
                                              withXPosition:-1
                                              withYPosition:-1
                                                  withWidth:1
                                                 withHeight:1
                                           withBorrderWidth:0
                                               withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                                               withVisualId:visual
                                              withValueMask:0
                                              withValueList:NULL];
    
    [ewmhService putPropertiesForRootWindow:rootWindow andWmWindow:wmWindow];
    
    xcb_generic_event_t *e;
    
    [connection mapWindow:wmWindow];
    [connection flush];
    
    while ((e = xcb_wait_for_event ([connection connection]))) {
        switch (e->response_type & ~0x80) {
            case XCB_EXPOSE:
            {
                [connection flush];
                break;
            }
            default: {
                
                break;
            }
        }
        
        free (e);
    }

    
    pause();
}

@end
