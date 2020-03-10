//
//  EWMH.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XCBConnection.h"
#import "XCBWindow.h"
#import "XCBAtomService.h"

//Actually it is a singleton

@interface EWMHService : NSObject
{
    // Root window properties (some are also messages too)
    /*NSString* EWMHSupported;
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
    NSString* UTF8_STRING;
    
    //GNUstep properties
    NSString *GNUStepMiniaturizeWindow;
    NSString *GNUStepHideApp;
    NSString *GNUStepWmAttr;
    NSString *GNUStepTitleBarState;
    NSString *GNUStepFrameOffset;
    
    //Added EWMH properties
    
    NSString *EWMHStartupId;
    NSString *EWMHFrameExtents;
    NSString *EWMHStrutPartial;
    NSString *EWMHVisibleIconName;*/
    
}

@property (strong, nonatomic) NSArray *atoms;
@property (strong, nonatomic) XCBConnection *connection;
@property (strong, nonatomic) XCBAtomService *atomService;


// Root window properties (some are also messages too)
@property (strong, nonatomic)NSString* EWMHSupported;
@property (strong, nonatomic)NSString* EWMHClientList;
@property (strong, nonatomic)NSString* EWMHClientListStacking;
@property (strong, nonatomic)NSString* EWMHNumberOfDesktops;
@property (strong, nonatomic)NSString* EWMHDesktopGeometry;
@property (strong, nonatomic)NSString* EWMHDesktopViewport;
@property (strong, nonatomic)NSString* EWMHCurrentDesktop;
@property (strong, nonatomic)NSString* EWMHDesktopNames;
@property (strong, nonatomic)NSString* EWMHActiveWindow;
@property (strong, nonatomic)NSString* EWMHWorkarea;
@property (strong, nonatomic)NSString* EWMHSupportingWMCheck;
@property (strong, nonatomic)NSString* EWMHVirtualRoots;
@property (strong, nonatomic)NSString* EWMHDesktopLayout;
@property (strong, nonatomic)NSString* EWMHShowingDesktop;

// Root Window Messages
@property (strong, nonatomic)NSString* EWMHCloseWindow;
@property (strong, nonatomic)NSString* EWMHMoveresizeWindow;
@property (strong, nonatomic)NSString* EWMHWMMoveresize;
@property (strong, nonatomic)NSString* EWMHRestackWindow;
@property (strong, nonatomic)NSString* EWMHRequestFrameExtents;

// Application window properties
@property (strong, nonatomic)NSString* EWMHWMName;
@property (strong, nonatomic)NSString* EWMHWMVisibleName;
@property (strong, nonatomic)NSString* EWMHWMIconName;
@property (strong, nonatomic)NSString* EWMHWMVisibleIconName;
@property (strong, nonatomic)NSString* EWMHWMDesktop;
@property (strong, nonatomic)NSString* EWMHWMWindowType;
@property (strong, nonatomic)NSString* EWMHWMState;
@property (strong, nonatomic)NSString* EWMHWMAllowedActions;
@property (strong, nonatomic)NSString* EWMHWMStrut;
@property (strong, nonatomic)NSString* EWMHWMStrutPartial;
@property (strong, nonatomic)NSString* EWMHWMIconGeometry;
@property (strong, nonatomic)NSString* EWMHWMIcon;
@property (strong, nonatomic)NSString* EWMHWMPid;
@property (strong, nonatomic)NSString* EWMHWMHandledIcons;
@property (strong, nonatomic)NSString* EWMHWMUserTime;
@property (strong, nonatomic)NSString* EWMHWMUserTimeWindow;
@property (strong, nonatomic)NSString* EWMHWMFrameExtents;

// The window types (used with EWMH_WMWindowType)
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDesktop;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDock;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeToolbar;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeMenu;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeUtility;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeSplash;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDialog;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDropdownMenu;
@property (strong, nonatomic)NSString* EWMHWMWindowTypePopupMenu;

@property (strong, nonatomic)NSString* EWMHWMWindowTypeTooltip;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeNotification;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeCombo;
@property (strong, nonatomic)NSString* EWMHWMWindowTypeDnd;

@property (strong, nonatomic)NSString* EWMHWMWindowTypeNormal;

// The application window states (used with EWMH_WMWindowState)
@property (strong, nonatomic)NSString* EWMHWMStateModal;
@property (strong, nonatomic)NSString* EWMHWMStateSticky;
@property (strong, nonatomic)NSString* EWMHWMStateMaximizedVert;
@property (strong, nonatomic)NSString* EWMHWMStateMaximizedHorz;
@property (strong, nonatomic)NSString* EWMHWMStateShaded;
@property (strong, nonatomic)NSString* EWMHWMStateSkipTaskbar;
@property (strong, nonatomic)NSString* EWMHWMStateSkipPager;
@property (strong, nonatomic)NSString* EWMHWMStateHidden;
@property (strong, nonatomic)NSString* EWMHWMStateFullscreen;
@property (strong, nonatomic)NSString* EWMHWMStateAbove;
@property (strong, nonatomic)NSString* EWMHWMStateBelow;
@property (strong, nonatomic)NSString* EWMHWMStateDemandsAttention;

// The application window allowed actions (used with EWMH_WMAllowedActions)
@property (strong, nonatomic)NSString* EWMHWMActionMove;
@property (strong, nonatomic)NSString* EWMHWMActionResize;
@property (strong, nonatomic)NSString* EWMHWMActionMinimize;
@property (strong, nonatomic)NSString* EWMHWMActionShade;
@property (strong, nonatomic)NSString* EWMHWMActionStick;
@property (strong, nonatomic)NSString* EWMHWMActionMaximizeHorz;
@property (strong, nonatomic)NSString* EWMHWMActionMaximizeVert;
@property (strong, nonatomic)NSString* EWMHWMActionFullscreen;
@property (strong, nonatomic)NSString* EWMHWMActionChangeDesktop;
@property (strong, nonatomic)NSString* EWMHWMActionClose;
@property (strong, nonatomic)NSString* EWMHWMActionAbove;
@property (strong, nonatomic)NSString* EWMHWMActionBelow;

// Window Manager Protocols
@property (strong, nonatomic)NSString* EWMHWMPing;
@property (strong, nonatomic)NSString* EWMHWMSyncRequest;
@property (strong, nonatomic)NSString* EWMHWMFullscreenMonitors;

// Other properties
@property (strong, nonatomic)NSString* EWMHWMFullPlacement;
@property (strong, nonatomic)NSString* UTF8_STRING;
@property (strong, nonatomic)NSString* MANAGER;

//GNUstep properties
@property (strong, nonatomic)NSString *GNUStepMiniaturizeWindow;
@property (strong, nonatomic)NSString *GNUStepHideApp;
@property (strong, nonatomic)NSString *GNUStepWmAttr;
@property (strong, nonatomic)NSString *GNUStepTitleBarState;
@property (strong, nonatomic)NSString *GNUStepFrameOffset;

//Added EWMH properties

@property (strong, nonatomic)NSString *EWMHStartupId;
@property (strong, nonatomic)NSString *EWMHFrameExtents;
@property (strong, nonatomic)NSString *EWMHStrutPartial;
@property (strong, nonatomic)NSString *EWMHVisibleIconName;

//this enum now is useless

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
    GNUStepFrameOffsetIndex,
    EWMHStartupIdIndex,
    EWMHFrameExtentsIndex,
    EWMHStrutPartialIndex,
    EWMHVisibleIconName,
    UTF8_STRING,
    MANAGER

};

+ (id) sharedInstanceWithConnection:(XCBConnection*)aConnection;

- (void) putPropertiesForRootWindow:(XCBWindow*) rootWindow andWmWindow:(XCBWindow*) wmWindow;

- (void) changePropertiesForWindow:(XCBWindow*) aWindow
                          withMode:(uint8_t) mode
                      withProperty:(NSString*) propertyKey
                          withType:(xcb_atom_t) type
                        withFormat:(uint8_t) format
                    withDataLength:(uint32_t) dataLength
                          withData:(const void *) data;

- (void*) getProperty:(NSString*) aPropertyName
           forWindow:(XCBWindow*)aWindow
              delete:(BOOL)deleteProperty ;

- (void) dealloc;

@end
