//
//  EWMH.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EWMH : NSObject
{
    // Root window properties (some are also messages too)
    NSString* EWMHSupported;
    NSString* EWMHClientList;
    NSString* EWMHClientListStacking;
    NSString* EWMHNumberOfDesktops;
    NSString* EWMHDesktopGeometry;
    NSString* EWMHDesktopViewport;
    NSString* EWMHCurrentDesktop;
    NSString* EWMHDesktopNames;
    NSString* EWMHActiveWindow;
    NSString* EWMHWorkarea;
    NSString* EWMHSupportingWMCheck;
    NSString* EWMHVirtualRoots;
    NSString* EWMHDesktopLayout;
    NSString* EWMHShowingDesktop;
    
    // Root Window Messages
    NSString* EWMHCloseWindow;
    NSString* EWMHMoveresizeWindow;
    NSString* EWMHWMMoveresize;
    NSString* EWMHRestackWindow;
    NSString* EWMHRequestFrameExtents;
    
    // Application window properties
    NSString* EWMHWMName;
    NSString* EWMHWMVisibleName;
    NSString* EWMHWMIconName;
    NSString* EWMHWMVisibleIconName;
    NSString* EWMHWMDesktop;
    NSString* EWMHWMWindowType;
    NSString* EWMHWMState;
    NSString* EWMHWMAllowedActions;
    NSString* EWMHWMStrut;
    NSString* EWMHWMStrutPartial;
    NSString* EWMHWMIconGeometry;
    NSString* EWMHWMIcon;
    NSString* EWMHWMPid;
    NSString* EWMHWMHandledIcons;
    NSString* EWMHWMUserTime;
    NSString* EWMHWMUserTimeWindow;
    NSString* EWMHWMFrameExtents;
    
    // The window types (used with EWMH_WMWindowType)
    NSString* EWMHWMWindowTypeDesktop;
    NSString* EWMHWMWindowTypeDock;
    NSString* EWMHWMWindowTypeToolbar;
    NSString* EWMHWMWindowTypeMenu;
    NSString* EWMHWMWindowTypeUtility;
    NSString* EWMHWMWindowTypeSplash;
    NSString* EWMHWMWindowTypeDialog;
    NSString* EWMHWMWindowTypeDropdownMenu;
    NSString* EWMHWMWindowTypePopupMenu;
    
    NSString* EWMHWMWindowTypeTooltip;
    NSString* EWMHWMWindowTypeNotification;
    NSString* EWMHWMWindowTypeCombo;
    NSString* EWMHWMWindowTypeDnd;
    
    NSString* EWMHWMWindowTypeNormal;
    
    // The application window states (used with EWMH_WMWindowState)
    NSString* EWMHWMStateModal;
    NSString* EWMHWMStateSticky;
    NSString* EWMHWMStateMaximizedVert;
    NSString* EWMHWMStateMaximizedHorz;
    NSString* EWMHWMStateShaded;
    NSString* EWMHWMStateSkipTaskbar;
    NSString* EWMHWMStateSkipPager;
    NSString* EWMHWMStateHidden ;
    NSString* EWMHWMStateFullscreen;
    NSString* EWMHWMStateAbove;
    NSString* EWMHWMStateBelow;
    NSString* EWMHWMStateDemandsAttention;
    
    // The application window allowed actions (used with EWMH_WMAllowedActions)
    NSString* EWMHWMActionMove;
    NSString* EWMHWMActionResize;
    NSString* EWMHWMActionMinimize;
    NSString* EWMHWMActionShade;
    NSString* EWMHWMActionStick;
    NSString* EWMHWMActionMaximizeHorz;
    NSString* EWMHWMActionMaximizeVert;
    NSString* EWMHWMActionFullscreen;
    NSString* EWMHWMActionChangeDesktop;
    NSString* EWMHWMActionClose;
    NSString* EWMHWMActionAbove;
    NSString* EWMHWMActionBelow;
    
    // Window Manager Protocols
    NSString* EWMHWMPing;
    NSString* EWMHWMSyncRequest;
    NSString* EWMHWMFullscreenMonitors;
    
    // Other properties
    NSString* EWMHWMFullPlacement;
    
    //GNUstep properties
    NSString *GNUStepMiniaturizeWindow;
    NSString *GNUStepHideApp;
    NSString *GNUStepWmAttr;
    NSString *GNUStepTitleBarState;
    NSString *GNUStepFrameOffset;
}

@property (strong, nonatomic) NSArray *atoms;


typedef NS_ENUM(NSUInteger, EWMHNames)
{
    EWMHSupported,
    EWMHClientList,
    EWMHClientListStacking,
    EWMHNumberOfDesktops,
    EWMHDesktopGeometry,
    EWMHDesktopViewport,
    EWMHCurrentDesktop,
    EWMHDesktopNames,
    EWMHActiveWindow,
    EWMHWorkarea,
    EWMHSupportingWMCheck,
    EWMHVirtualRoots,
    EWMHDesktopLayout,
    EWMHShowingDesktop,
    EWMHCloseWindow,
    EWMHMoveresizeWindow,
    EWMHWMMoveresize,
    EWMHRestackWindow,
    EWMHRequestFrameExtents,
    EWMHWMName,
    EWMHWMVisibleName,
    EWMHWMIconName,
    EWMHWMVisibleIconName,
    EWMHWMDesktop,
    EWMHWMWindowType,
    EWMHWMState,
    EWMHWMAllowedActions,
    EWMHWMStrut,
    EWMHWMStrutPartial,
    EWMHWMIconGeometry,
    EWMHWMIcon,
    EWMHWMPid,
    EWMHWMHandledIcons,
    EWMHWMUserTime,
    EWMHWMUserTimeWindow,
    EWMHWMFrameExtents,
    EWMHWMWindowTypeDesktop,
    EWMHWMWindowTypeDock,
    EWMHWMWindowTypeToolbar,
    EWMHWMWindowTypeMenu,
    EWMHWMWindowTypeUtility,
    EWMHWMWindowTypeSplash,
    EWMHWMWindowTypeDialog,
    EWMHWMWindowTypeDropdownMenu,
    EWMHWMWindowTypePopupMenu,
    EWMHWMWindowTypeTooltip,
    EWMHWMWindowTypeNotification,
    EWMHWMWindowTypeCombo,
    EWMHWMWindowTypeDnd,
    EWMHWMWindowTypeNormal,
    EWMHWMStateModal,
    EWMHWMStateSticky,
    EWMHWMStateMaximizedVert,
    EWMHWMStateMaximizedHorz,
    EWMHWMStateShaded,
    EWMHWMStateSkipTaskbar,
    EWMHWMStateSkipPager,
    EWMHWMStateHidden,
    EWMHWMStateFullscreen,
    EWMHWMStateAbove,
    EWMHWMStateBelow,
    EWMHWMStateDemandsAttention,
    EWMHWMActionMove,
    EWMHWMActionResize,
    EWMHWMActionMinimize,
    EWMHWMActionShade,
    EWMHWMActionStick,
    EWMHWMActionMaximizeHorz,
    EWMHWMActionMaximizeVert,
    EWMHWMActionFullscreen,
    EWMHWMActionChangeDesktop,
    EWMHWMActionClose,
    EWMHWMActionAbove,
    EWMHWMActionBelow,
    EWMHWMPing,
    EWMHWMSyncRequest,
    EWMHWMFullscreenMonitors,
    EWMHWMFullPlacement,
    GNUStepMiniaturizeWindow,
    GNUStepHideApp,
    GNUStepWmAttr,
    GNUStepTitleBarState,
    GNUStepFrameOffset

};

- (id) init;

@end
