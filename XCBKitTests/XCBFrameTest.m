//
//  XCBFrameTest.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/08/19.
//  Copyright (c) 2019 alex. All rights reserved.
//

#import "XCBFrameTest.h"
#import "XCBFrame.h"
#import "XCBTitleBar.h"
#import "XCBConnection.h"

@implementation XCBFrameTest

- (void) testFrame
{
    XCBConnection *connection = [XCBConnection sharedConnection];
    XCBWindow *clientWindow = [[XCBWindow alloc] initWithXCBWindow:xcb_generate_id([connection connection])];
    XCBPoint *coordinates = [[XCBPoint alloc] initWithX:1 andY:1];
    XCBSize *sizes = [[XCBSize alloc] initWithWidht:150 andHeight:150];
    XCBRect *windowRect = [[XCBRect alloc] initWithPoint:coordinates andSize:sizes];
    [clientWindow setWindowRect:windowRect];
    
    
    XCBSize *frameSize = [[XCBSize alloc] initWithWidht:[sizes getWidth] + 1 andHeight:[sizes getHeight] + 1];
    
    
    XCBScreen *screen = [[connection screens] objectAtIndex:0];
    XCBVisual *visual = [[XCBVisual alloc] initWithVisualId:[screen screen].root_visual];
    
    
    XCBWindow *frameWindow = [connection createWindowWithDepth:XCB_COPY_FROM_PARENT
                     withParentWindow:[screen rootWindow]
                        withXPosition:[coordinates getX]
                        withYPosition:[coordinates getY]
                            withWidth:[frameSize getWidth]
                           withHeight:[frameSize getHeight]
                     withBorrderWidth:10
                         withXCBClass:XCB_WINDOW_CLASS_INPUT_OUTPUT
                         withVisualId:visual
                        withValueMask:0
                        withValueList:NULL];
    
    XCBFrame *frame = [[XCBFrame alloc] initWithClientWindow:clientWindow
                                              withConnection:connection
                                               withXcbWindow:[frameWindow window]];
    
    XCBRect *frameRect = [[XCBRect alloc] initWithPoint:coordinates andSize: frameSize];
    [frame setWindowRect:frameRect];


    [frame setWindow:[frameWindow window]];
    [frame setParentWindow:[frameWindow parentWindow]];
    [frame setAboveWindow:[frameWindow aboveWindow]];
    [frame setIsMapped:[frameWindow isMapped]];
    [frame setAttributes:[frameWindow attributes]];
    
    frameWindow = nil;
    
    [connection mapWindow:frame];
    
    XCBTitleBar *titleBar = [[XCBTitleBar alloc] initWithFrame:frame withConnection:connection];
    [frame addChildWindow:titleBar withKey:TitleBar];
    
    [connection flush];
    
    NSUInteger dicionarySize = [[frame getChildren] count];
    NSUInteger knownChildren = 2;
    
    STAssertEquals(dicionarySize, knownChildren, @"Not equals");
    
    pause();
    
}

@end
