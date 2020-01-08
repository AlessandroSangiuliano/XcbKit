//
//  EWMH.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCBConnection.h>

//Actually it is a singleton

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
@property (strong, nonatomic) XCBConnection *connection;


typedef NS_ENUM(NSUInteger, EWMHNames)
{
    EWMHSupportedIndex,
    EWMHClientListIndex,
    EWMHClientListStackingIndex,
    EWMHNumberOfDesktopsIndex,
    EWMHDesktopGeometryIndex,
    EWMHDesktopViewportIndex,
    EWMHCurrentDesktopIndex,
    EWMHDesktopNamesIndex,
    EWMHActiveWindowIndex,
    EWMHWorkareaIndex,
    EWMHSupportingWMCheckIndex,
    EWMHVirtualRootsIndex,
    EWMHDesktopLayoutIndex,
    EWMHShowingDesktopIndex,
    EWMHCloseWindowIndex,
    EWMHMoveresizeWindowIndex,
    EWMHWMMoveresizeIndex,
    EWMHRestackWindowIndex,
    EWMHRequestFrameExtentsIndex,
    EWMHWMNameIndex,
    EWMHWMVisibleNameIndex,
    EWMHWMIconNameIndex,
    EWMHWMVisibleIconNameIndex,
    EWMHWMDesktopIndex,
    EWMHWMWindowTypeIndex,
    EWMHWMStateIndex,
    EWMHWMAllowedActionsIndex,
    EWMHWMStrutIndex,
    EWMHWMStrutPartialIndex,
    EWMHWMIconGeometryIndex,
    EWMHWMIconIndex,
    EWMHWMPidIndex,
    EWMHWMHandledIconsIndex,
    EWMHWMUserTimeIndex,
    EWMHWMUserTimeWindowIndex,
    EWMHWMFrameExtentsIndex,
    EWMHWMWindowTypeDesktopIndex,
    EWMHWMWindowTypeDockIndex,
    EWMHWMWindowTypeToolbarIndex,
    EWMHWMWindowTypeMenuIndex,
    EWMHWMWindowTypeUtilityIndex,
    EWMHWMWindowTypeSplashIndex,
    EWMHWMWindowTypeDialogIndex,
    EWMHWMWindowTypeDropdownMenuIndex,
    EWMHWMWindowTypePopupMenuIndex,
    EWMHWMWindowTypeTooltipIndex,
    EWMHWMWindowTypeNotificationIndex,
    EWMHWMWindowTypeComboIndex,
    EWMHWMWindowTypeDndIndex,
    EWMHWMWindowTypeNormalIndex,
    EWMHWMStateModalIndex,
    EWMHWMStateStickyIndex,
    EWMHWMStateMaximizedVertIndex,
    EWMHWMStateMaximizedHorzIndex,
    EWMHWMStateShadedIndex,
    EWMHWMStateSkipTaskbarIndex,
    EWMHWMStateSkipPagerIndex,
    EWMHWMStateHiddenIndex,
    EWMHWMStateFullscreenIndex,
    EWMHWMStateAboveIndex,
    EWMHWMStateBelowIndex,
    EWMHWMStateDemandsAttentionIndex,
    EWMHWMActionMoveIndex,
    EWMHWMActionResizeIndex,
    EWMHWMActionMinimizeIndex,
    EWMHWMActionShadeIndex,
    EWMHWMActionStickIndex,
    EWMHWMActionMaximizeHorzIndex,
    EWMHWMActionMaximizeVertIndex,
    EWMHWMActionFullscreenIndex,
    EWMHWMActionChangeDesktopIndex,
    EWMHWMActionCloseIndex,
    EWMHWMActionAboveIndex,
    EWMHWMActionBelowIndex,
    EWMHWMPingIndex,
    EWMHWMSyncRequestIndex,
    EWMHWMFullscreenMonitorsIndex,
    EWMHWMFullPlacementIndex,
    GNUStepMiniaturizeWindowIndex,
    GNUStepHideAppIndex,
    GNUStepWmAttrIndex,
    GNUStepTitleBarStateIndex,
    GNUStepFrameOffsetIndex

};

+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection;

//- (id) initWithConnection:(XCBConnection*)aConnection; make it private

- (void) dealloc;

@end
