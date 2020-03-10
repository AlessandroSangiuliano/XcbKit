//
//  TransformersTest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 11/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "Transformers.h"
#import "XCBAtomService.h"
#import "XCBConnection.h"

@interface TransformersTest : SenTestCase

@end

@implementation TransformersTest

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

- (void)testFromNSArrayToCArray
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBAtomService *atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    
    NSString *supported = @"_NET_SUPPORTED";
    NSString *wmName = @"_NET_WM_NAME";
    
    [atomService cacheAtom:supported];
    [atomService cacheAtom:wmName];
    
    NSString *strings[] = {supported, wmName};
    
    NSArray *array = [NSArray arrayWithObjects:strings count:sizeof(strings) / sizeof(NSString*)];
    
    xcb_atom_t *transformed = FnFromNSArrayAtomsToXcbAtomTArray(array, atomService);
    
    STAssertEquals(sizeof(transformed)/sizeof(xcb_atom_t), 2ul, @"Expected: 2");
}

@end
