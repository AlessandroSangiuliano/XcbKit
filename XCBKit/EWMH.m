//
//  EWMH.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "EWMH.h"

@implementation EWMH

@synthesize atoms;

- (id) init
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init!");
        return nil;
    }
    
    // Root window properties (some are also messages too)
    
    EWMHSupported = @"_NET_SUPPORTED";
    EWMHClientList = @"_NET_CLIENT_LIST";
    EWMHClientListStacking = @"_NET_CLIENT_LIST_STACKING";
    EWMHNumberOfDesktops = @"_NET_NUMBER_OF_DESKTOPS";
    EWMHDesktopGeometry = @"_NET_DESKTOP_GEOMETRY";
    EWMHDesktopViewport = @"_NET_DESKTOP_VIEWPORT";
    EWMHCurrentDesktop = @"_NET_CURRENT_DESKTOP";
    EWMHDesktopNames = @"_NET_DESKTOP_NAMES";
    EWMHActiveWindow = @"_NET_ACTIVE_WINDOW";
    EWMHWorkarea = @"_NET_WORKAREA";
    EWMHSupportingWMCheck = @"_NET_SUPPORTING_WM_CHECK";
    EWMHVirtualRoots = @"_NET_VIRTUAL_ROOTS";
    EWMHDesktopLayout = @"_NET_DESKTOP_LAYOUT";
    EWMHShowingDesktop = @"_NET_SHOWING_DESKTOP";
    
    // Root Window Messages
    EWMHCloseWindow = @"_NET_CLOSE_WINDOW";
    EWMHMoveresizeWindow = @"_NET_MOVERESIZE_WINDOW";
    EWMHWMMoveresize = @"_NET_WM_MOVERESIZE";
    EWMHRestackWindow = @"_NET_RESTACK_WINDOW";
    EWMHRequestFrameExtents = @"_NET_REQUEST_FRAME_EXTENTS";
    
    // Application window properties
    EWMHWMName = @"_NET_WM_NAME";
    EWMHWMVisibleName = @"_NET_WM_VISIBLE_NAME";
    EWMHWMIconName = @"_NET_WM_ICON_NAME";
    EWMHWMVisibleIconName = @"_NET_WM_VISIBLE_ICON_NAME";
    EWMHWMDesktop = @"_NET_WM_DESKTOP";
    EWMHWMWindowType = @"_NET_WM_WINDOW_TYPE";
    EWMHWMState = @"_NET_WM_STATE";
    EWMHWMAllowedActions = @"_NET_WM_ALLOWED_ACTIONS";
    EWMHWMStrut = @"_NET_WM_STRUT";
    EWMHWMStrutPartial = @"_NET_WM_STRUT_PARTIAL";
    EWMHWMIconGeometry = @"_NET_WM_ICON_GEOMETRY";
    EWMHWMIcon = @"_NET_WM_ICON";
    EWMHWMPid = @"_NET_WM_PID";
    EWMHWMHandledIcons = @"_NET_WM_HANDLED_ICONS";
    EWMHWMUserTime = @"_NET_WM_USER_TIME";
    EWMHWMUserTimeWindow = @"_NET_WM_USER_TIME_WINDOW";
    EWMHWMFrameExtents = @"_NET_FRAME_EXTENTS";
    
    // The window types (used with EWMH_WMWindowType)
    EWMHWMWindowTypeDesktop = @"_NET_WM_WINDOW_TYPE_DESKTOP";
    EWMHWMWindowTypeDock = @"_NET_WM_WINDOW_TYPE_DOCK";
    EWMHWMWindowTypeToolbar = @"_NET_WM_WINDOW_TYPE_TOOLBAR";
    EWMHWMWindowTypeMenu = @"_NET_WM_WINDOW_TYPE_MENU";
    EWMHWMWindowTypeUtility = @"_NET_WM_WINDOW_TYPE_UTILITY";
    EWMHWMWindowTypeSplash = @"_NET_WM_WINDOW_TYPE_SPLASH";
    EWMHWMWindowTypeDialog = @"_NET_WM_WINDOW_TYPE_DIALOG";
    EWMHWMWindowTypeDropdownMenu = @"_NET_WM_WINDOW_TYPE_DROPDOWN_MENU";
    EWMHWMWindowTypePopupMenu = @"_NET_WM_WINDOW_TYPE_POPUP_MENU";
    
    EWMHWMWindowTypeTooltip = @"_NET_WM_WINDOW_TYPE_TOOLTIP";
    EWMHWMWindowTypeNotification = @"_NET_WM_WINDOW_TYPE_NOTIFICATION";
    EWMHWMWindowTypeCombo = @"_NET_WM_WINDOW_TYPE_COMBO";
    EWMHWMWindowTypeDnd = @"_NET_WM_WINDOW_TYPE_DND";
    
    EWMHWMWindowTypeNormal = @"_NET_WM_WINDOW_TYPE_NORMAL";
    
    // The application window states (used with EWMH_WMWindowState)
    EWMHWMStateModal = @"_NET_WM_STATE_MODAL";
    EWMHWMStateSticky = @"_NET_WM_STATE_STICKY";
    EWMHWMStateMaximizedVert = @"_NET_WM_STATE_MAXIMIZED_VERT";
    EWMHWMStateMaximizedHorz = @"_NET_WM_STATE_MAXIMIZED_HORZ";
    EWMHWMStateShaded = @"_NET_WM_STATE_SHADED";
    EWMHWMStateSkipTaskbar = @"_NET_WM_STATE_SKIP_TASKBAR";
    EWMHWMStateSkipPager = @"_NET_WM_STATE_SKIP_PAGER";
    EWMHWMStateHidden = @"_NET_WM_STATE_HIDDEN";
    EWMHWMStateFullscreen = @"_NET_WM_STATE_FULLSCREEN";
    EWMHWMStateAbove = @"_NET_WM_STATE_ABOVE";
    EWMHWMStateBelow = @"_NET_WM_STATE_BELOW";
    EWMHWMStateDemandsAttention = @"_NET_WM_STATE_DEMANDS_ATTENTION";
    
    // The application window allowed actions (used with EWMH_WMAllowedActions)
    EWMHWMActionMove = @"_NET_WM_ACTION_MOVE";
    EWMHWMActionResize = @"_NET_WM_ACTION_RESIZE";
    EWMHWMActionMinimize = @"_NET_WM_ACTION_MINIMIZE";
    EWMHWMActionShade = @"_NET_WM_ACTION_SHADE";
    EWMHWMActionStick = @"_NET_WM_ACTION_STICK";
    EWMHWMActionMaximizeHorz = @"_NET_WM_ACTION_MAXIMIZE_HORZ";
    EWMHWMActionMaximizeVert = @"_NET_WM_ACTION_MAXIMIZE_VERT";
    EWMHWMActionFullscreen = @"_NET_WM_ACTION_FULLSCREEN";
    EWMHWMActionChangeDesktop = @"_NET_WM_ACTION_CHANGE_DESKTOP";
    EWMHWMActionClose = @"_NET_WM_ACTION_CLOSE";
    EWMHWMActionAbove = @"_NET_WM_ACTION_ABOVE";
    EWMHWMActionBelow = @"_NET_WM_ACTION_BELOW";
    
    // Window Manager Protocols
    EWMHWMPing = @"_NET_WM_PING";
    EWMHWMSyncRequest = @"_NET_WM_SYNC_REQUEST";
    EWMHWMFullscreenMonitors = @"_NET_WM_FULLSCREEN_MONITORS";
    
    // Other properties
    EWMHWMFullPlacement = @"_NET_WM_FULL_PLACEMENT";
    
    //GNUStep properties
    
    GNUStepMiniaturizeWindow = @"_GNUSTEP_WM_MINIATURIZE_WINDOW";
    GNUStepHideApp = @"_GNUSTEP_WM_HIDE_APP";
    GNUStepFrameOffset = @"_GNUSTEP_FRAME_OFFSETS";
    GNUStepWmAttr = @"_GNUSTEP_WM_ATTR";
    GNUStepTitleBarState = @"_GNUSTEP_FRAME_OFFSETS";
    
    //Array iitialization
    NSString* atomStrings[] = {
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
    
    atoms = [NSArray arrayWithObjects:atomStrings count:sizeof(atomStrings)/sizeof(NSString*)];
    
    return self;
}

@end
