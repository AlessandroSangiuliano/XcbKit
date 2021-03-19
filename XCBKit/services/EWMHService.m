//
//  EWMH.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 07/01/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "EWMHService.h"
#import "../functions/Transformers.h"
#import "../enums/EEwmh.h"
#import "../services/TitleBarSettingsService.h"

@implementation EWMHService

@synthesize atoms;
@synthesize connection;
@synthesize atomService;


// Root window properties (some are also messages too)
@synthesize EWMHSupported;
@synthesize EWMHClientList;
@synthesize EWMHClientListStacking;
@synthesize EWMHNumberOfDesktops;
@synthesize EWMHDesktopGeometry;
@synthesize EWMHDesktopViewport;
@synthesize EWMHCurrentDesktop;
@synthesize EWMHDesktopNames;
@synthesize EWMHActiveWindow;
@synthesize EWMHWorkarea;
@synthesize EWMHSupportingWMCheck;
@synthesize EWMHVirtualRoots;
@synthesize EWMHDesktopLayout;
@synthesize EWMHShowingDesktop;

// Root Window Messages
@synthesize EWMHCloseWindow;
@synthesize EWMHMoveresizeWindow;
@synthesize EWMHWMMoveresize;
@synthesize EWMHRestackWindow;
@synthesize EWMHRequestFrameExtents;

// Application window properties
@synthesize EWMHWMName;
@synthesize EWMHWMVisibleName;
@synthesize EWMHWMIconName;
@synthesize EWMHWMVisibleIconName;
@synthesize EWMHWMDesktop;
@synthesize EWMHWMWindowType;
@synthesize EWMHWMState;
@synthesize EWMHWMAllowedActions;
@synthesize EWMHWMStrut;
@synthesize EWMHWMStrutPartial;
@synthesize EWMHWMIconGeometry;
@synthesize EWMHWMIcon;
@synthesize EWMHWMPid;
@synthesize EWMHWMHandledIcons;
@synthesize EWMHWMUserTime;
@synthesize EWMHWMUserTimeWindow;
@synthesize EWMHWMFrameExtents;

// The window types (used with EWMH_WMWindowType)
@synthesize EWMHWMWindowTypeDesktop;
@synthesize EWMHWMWindowTypeDock;
@synthesize EWMHWMWindowTypeToolbar;
@synthesize EWMHWMWindowTypeMenu;
@synthesize EWMHWMWindowTypeUtility;
@synthesize EWMHWMWindowTypeSplash;
@synthesize EWMHWMWindowTypeDialog;
@synthesize EWMHWMWindowTypeDropdownMenu;
@synthesize EWMHWMWindowTypePopupMenu;

@synthesize EWMHWMWindowTypeTooltip;
@synthesize EWMHWMWindowTypeNotification;
@synthesize EWMHWMWindowTypeCombo;
@synthesize EWMHWMWindowTypeDnd;

@synthesize EWMHWMWindowTypeNormal;

// The application window states (used with EWMH_WMWindowState)
@synthesize EWMHWMStateModal;
@synthesize EWMHWMStateSticky;
@synthesize EWMHWMStateMaximizedVert;
@synthesize EWMHWMStateMaximizedHorz;
@synthesize EWMHWMStateShaded;
@synthesize EWMHWMStateSkipTaskbar;
@synthesize EWMHWMStateSkipPager;
@synthesize EWMHWMStateHidden ;
@synthesize EWMHWMStateFullscreen;
@synthesize EWMHWMStateAbove;
@synthesize EWMHWMStateBelow;
@synthesize EWMHWMStateDemandsAttention;

// The application window allowed actions (used with EWMH_WMAllowedActions)
@synthesize EWMHWMActionMove;
@synthesize EWMHWMActionResize;
@synthesize EWMHWMActionMinimize;
@synthesize EWMHWMActionShade;
@synthesize EWMHWMActionStick;
@synthesize EWMHWMActionMaximizeHorz;
@synthesize EWMHWMActionMaximizeVert;
@synthesize EWMHWMActionFullscreen;
@synthesize EWMHWMActionChangeDesktop;
@synthesize EWMHWMActionClose;
@synthesize EWMHWMActionAbove;
@synthesize EWMHWMActionBelow;

// Window Manager Protocols
@synthesize EWMHWMPing;
@synthesize EWMHWMSyncRequest;
@synthesize EWMHWMFullscreenMonitors;

// Other properties
@synthesize EWMHWMFullPlacement;
@synthesize UTF8_STRING;
@synthesize MANAGER;
@synthesize KdeNetWFrameStrut;
@synthesize MotifWMHints;

//GNUstep properties
@synthesize GNUStepMiniaturizeWindow;
@synthesize GNUStepHideApp;
@synthesize GNUStepWmAttr;
@synthesize GNUStepTitleBarState;
@synthesize GNUStepFrameOffset;

//Added EWMH properties

@synthesize EWMHStartupId;
@synthesize EWMHFrameExtents;
@synthesize EWMHStrutPartial;
@synthesize EWMHVisibleIconName;

- (id) initWithConnection:(XCBConnection*)aConnection
{
    self = [super init];

    if (self == nil)
    {
        NSLog(@"Unable to init!");
        return nil;
    }

    connection = aConnection;

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
    UTF8_STRING = @"UTF8_STRING";
    MANAGER = @"MANAGER";
    KdeNetWFrameStrut = @"_KDE_NET_WM_FRAME_STRUT";
    MotifWMHints = @"_MOTIF_WM_HINTS";

    //GNUStep properties

    GNUStepMiniaturizeWindow = @"_GNUSTEP_WM_MINIATURIZE_WINDOW";
    GNUStepHideApp = @"_GNUSTEP_WM_HIDE_APP";
    GNUStepFrameOffset = @"_GNUSTEP_FRAME_OFFSETS";
    GNUStepWmAttr = @"_GNUSTEP_WM_ATTR";
    GNUStepTitleBarState = @"_GNUSTEP_TITLEBAR_STATE";

    // Added EWMH properties

    EWMHStartupId = @"_NET_STARTUP_ID";
    EWMHFrameExtents = @"_NET_FRAME_EXTENTS";
    EWMHStrutPartial = @"_NET_WM_STRUT_PARTIAL";
    EWMHVisibleIconName = @"_NET_WM_VISIBLE_ICON_NAME";

    //Array iitialization
    NSString* atomStrings[] =
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
        //EWMHRequestFrameExtents,
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
        GNUStepFrameOffset,
        EWMHStartupId,
        EWMHFrameExtents,
        EWMHStrutPartial,
        EWMHVisibleIconName,
        UTF8_STRING,
        MANAGER,
        KdeNetWFrameStrut,
        MotifWMHints
    };

    atoms = [NSArray arrayWithObjects:atomStrings count:sizeof(atomStrings)/sizeof(NSString*)];
    atomService = [XCBAtomService sharedInstanceWithConnection:connection];
    [atomService cacheAtoms:atoms];

    return self;
}

+ (id) sharedInstanceWithConnection:(XCBConnection *)aConnection
{
    static EWMHService *sharedInstance = nil;

    // this is not thread safe, switch to libdispatch some day.
    if (sharedInstance == nil)
    {
        sharedInstance = [[self alloc] initWithConnection:aConnection];
    }

    return sharedInstance;
}

- (void) putPropertiesForRootWindow:(XCBWindow *)rootWindow andWmWindow:(XCBWindow *)wmWindow
{
    NSString *rootProperties[] =
    {
        EWMHSupported,
        EWMHSupportingWMCheck,
        EWMHStartupId,
        EWMHClientList,
        EWMHClientListStacking,
        EWMHNumberOfDesktops,
        EWMHCurrentDesktop,
        EWMHDesktopNames,
        EWMHActiveWindow,
        EWMHCloseWindow,
        EWMHFrameExtents,
        EWMHWMName,
        EWMHStrutPartial,
        EWMHWMIconName,
        EWMHVisibleIconName,
        EWMHWMDesktop,
        EWMHWMWindowType,
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
        EWMHWMIcon,
        EWMHWMPid,
        EWMHWMState,
        EWMHWMStateSticky,
        EWMHWMStateSkipTaskbar,
        EWMHWMStateFullscreen,
        EWMHWMStateMaximizedHorz,
        EWMHWMStateMaximizedVert,
        EWMHWMStateAbove,
        EWMHWMStateBelow,
        EWMHWMStateModal,
        EWMHWMStateHidden,
        EWMHWMStateDemandsAttention,
        //EWMHRequestFrameExtents,
        UTF8_STRING,
        GNUStepFrameOffset,
        GNUStepHideApp,
        GNUStepWmAttr,
        GNUStepMiniaturizeWindow,
        GNUStepTitleBarState,
        KdeNetWFrameStrut
    };

    NSArray *rootAtoms = [NSArray arrayWithObjects:rootProperties count:sizeof(rootProperties)/sizeof(NSString*)];

    xcb_atom_t atomsTransformed[[rootAtoms count]];
    FnFromNSArrayAtomsToXcbAtomTArray(rootAtoms, atomsTransformed, atomService);

    xcb_change_property([connection connection],
                        XCB_PROP_MODE_REPLACE,
                        [rootWindow window],
                        [[[atomService cachedAtoms] objectForKey:EWMHSupported] unsignedIntValue],
                        XCB_ATOM_ATOM,
                        32,
                        (uint32_t)[rootAtoms count],
                        &atomsTransformed);

    xcb_window_t wmXcbWindow = [wmWindow window];

    xcb_change_property([connection connection],
                        XCB_PROP_MODE_REPLACE,
                        [rootWindow window],
                        [[[atomService cachedAtoms] objectForKey:EWMHSupportingWMCheck] unsignedIntValue],
                        XCB_ATOM_WINDOW,
                        32,
                        1,
                        &wmXcbWindow);

    xcb_change_property([connection connection],
                        XCB_PROP_MODE_REPLACE,
                        wmXcbWindow,
                        [[[atomService cachedAtoms] objectForKey:EWMHSupportingWMCheck] unsignedIntValue],
                        XCB_ATOM_WINDOW,
                        32,
                        1,
                        &wmXcbWindow);

    xcb_change_property([connection connection],
                        XCB_PROP_MODE_REPLACE,
                        wmXcbWindow,
                        [[[atomService cachedAtoms] objectForKey:EWMHWMName] unsignedIntValue],
                        [[[atomService cachedAtoms] objectForKey:UTF8_STRING] unsignedIntValue],
                        8,
                        6,
                        "uroswm");


    int pid = getpid();

    xcb_change_property([connection connection],
                        XCB_PROP_MODE_REPLACE,
                        wmXcbWindow,
                        [[[atomService cachedAtoms] objectForKey:EWMHWMPid] unsignedIntValue],
                        XCB_ATOM_CARDINAL,
                        32,
                        1,
                        &pid);

    [self updateNetSupported:[[atomService cachedAtoms] allValues] forRootWindow:rootWindow];

    //TODO: wm-specs says that if the _NET_WM_PID is set the ICCCM WM_CLIENT_MACHINE atom must be set.

    rootAtoms = nil;

}

- (void) changePropertiesForWindow:(XCBWindow *)aWindow
                          withMode:(uint8_t)mode
                      withProperty:(NSString*)propertyKey
                          withType:(xcb_atom_t)type
                        withFormat:(uint8_t)format
                    withDataLength:(uint32_t)dataLength
                          withData:(const void *) data
{
    xcb_atom_t property = [atomService atomFromCachedAtomsWithKey:propertyKey];

    xcb_change_property([connection connection],
                        mode,
                        [aWindow window],
                        property,
                        type,
                        format,
                        dataLength,
                        data);
}


- (void*) getProperty:(NSString *)aPropertyName
         propertyType:(xcb_atom_t)propertyType
            forWindow:(XCBWindow *)aWindow
               delete:(BOOL)deleteProperty
               length:(uint32_t)len
{
    xcb_atom_t property = [atomService atomFromCachedAtomsWithKey:aPropertyName];

    xcb_get_property_cookie_t cookie = xcb_get_property([connection connection],
                                                        deleteProperty,
                                                        [aWindow window],
                                                        property,
                                                        propertyType,
                                                        0,
                                                        len);

    xcb_generic_error_t *error;
    xcb_get_property_reply_t *reply = xcb_get_property_reply([connection connection],
                                                             cookie,
                                                             &error);

    if (error)
    {
        NSLog(@"Error: %d for window: %u", error->error_code, [aWindow window]);
        free(error);
        return NULL;
    }

    if (reply->length == 0 && reply->format == 0 && reply->type == 0)
    {
        free(error);
        return NULL;
    }

    free(error);
    return reply;
}

- (void) updateNetFrameExtentsForWindow:(XCBWindow *)aWindow
{
    XCBGeometryReply *geometry = [aWindow geometries];
    uint32_t extents[4];
    uint32_t border = [geometry borderWidth];
    NSLog(@"Border: %d", border);


    extents[0] = border;
    extents[1] = border;
    extents[2] = 21;
    extents[3] = border;

    [self changePropertiesForWindow:aWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHWMFrameExtents
                           withType:XCB_ATOM_CARDINAL
                         withFormat:32
                     withDataLength:4
                           withData:extents];

    geometry = nil;
}

- (void) updateNetFrameExtentsForWindow:(XCBWindow*)aWindow andExtents:(uint32_t[]) extents
{
    [self changePropertiesForWindow:aWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHWMFrameExtents
                           withType:XCB_ATOM_CARDINAL
                         withFormat:32
                     withDataLength:4
                           withData:extents];
}

- (BOOL) ewmhClientMessage:(NSString *)anAtomMessageName
{
    NSString *net = @"NET";
    BOOL ewmh = NO;

    NSString *sub = [anAtomMessageName componentsSeparatedByString:@"_"][1];

    if ([net isEqualToString:sub])
        ewmh = YES;
    else
        ewmh = NO;

    net = nil;
    sub = nil;

    return ewmh;
}

- (void) handleClientMessage:(NSString*)anAtomMessageName forWindow:(XCBWindow*)aWindow data:(xcb_client_message_data_t)someData
{
    if ([anAtomMessageName isEqualToString:EWMHRequestFrameExtents])
    {
        uint32_t extents[] = {3,3,21,3};
        [self updateNetFrameExtentsForWindow:aWindow andExtents:extents];

        return;
    }

    /*** if it is _NET_ACTIVE_WINDOW, focus the window that updates the property too. ***/

    if ([anAtomMessageName isEqualToString:EWMHActiveWindow])
    {
        [aWindow focus];

        if ([[aWindow parentWindow] isKindOfClass:[XCBFrame class]])
        {
            XCBFrame *frame = (XCBFrame *) [aWindow parentWindow];
            XCBTitleBar *titleBar = (XCBTitleBar *) [frame childWindowForKey:TitleBar];
            [frame stackAbove];
            [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];
            [connection drawAllTitleBarsExcept:titleBar];
            frame = nil;
            titleBar = nil;
        }

        return;
    }

    if ([anAtomMessageName isEqualToString:EWMHWMState])
    {
        Action action = someData.data32[0];
        xcb_atom_t firstProp = someData.data32[1];
        xcb_atom_t secondProp = someData.data32[2];

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipTaskbar] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipTaskbar])
        {
            BOOL skipTaskBar = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow skipTaskBar]);
            [aWindow setSkipTaskBar:skipTaskBar];
            [self updateNetWmState:aWindow];
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipPager] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipPager])
        {
            BOOL skipPager = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow skipTaskBar]);
            [aWindow setSkipPager:skipPager];
            [self updateNetWmState:aWindow];
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateAbove] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateAbove])
        {
            BOOL above = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow isAbove]);

            if (above)
                [aWindow stackAbove];

            [self updateNetWmState:aWindow];
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateBelow] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateBelow])
        {
            BOOL below = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow isBelow]);

            if (below)
                [aWindow stackBelow];

            [self updateNetWmState:aWindow];
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedHorz] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedHorz])
        {
            BOOL maxHorz = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow maximizedHorizontally]);
            XCBScreen *screen = [aWindow screen];
            XCBSize size;
            XCBPoint position;
            XCBFrame *frame;
            XCBTitleBar *titleBar;
            TitleBarSettingsService *settingsService = [TitleBarSettingsService sharedInstance];

            uint16_t titleHgt = [settingsService heightDefined] ? [settingsService height] : [settingsService defaultHeight];

            if (maxHorz)
            {
                if ([aWindow isMinimized])
                    [aWindow restoreFromIconified];

                if ([aWindow decorated])
                {
                    frame = (XCBFrame*)[aWindow parentWindow];
                    titleBar = (XCBTitleBar*)[frame childWindowForKey:TitleBar];

                    /*** frame size and position ***/
                    size = XCBMakeSize([screen width], [frame windowRect].size.height);
                    [frame maximizeToSize:size andPosition:[frame windowRect].position];

                    /*** titlebar size and position ***/
                    size = XCBMakeSize([frame windowRect].size.width, titleHgt);
                    position = XCBMakePoint(0.0,0.0);
                    [titleBar maximizeToSize:size andPosition:position];
                    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

                    /*** client window size and position ***/
                    size = XCBMakeSize([frame windowRect].size.width - 2, [frame windowRect].size.height - titleHgt - 2);
                    position = XCBMakePoint(0.0, titleHgt - 1);

                    frame = nil;
                    titleBar = nil;
                }
                else
                {
                    size = XCBMakeSize([screen width], [aWindow windowRect].size.height);
                    position = XCBMakePoint([aWindow windowRect].position.x, [aWindow windowRect].position.y);
                }

                [aWindow maximizeToSize:size andPosition:position];
                [aWindow setMaximizedHorizontally:maxHorz];
                screen = nil;
            }

            [self updateNetWmState:aWindow];
            settingsService = nil;
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedVert] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedVert])
        {
            BOOL maxVert = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow maximizedVertically]);
            XCBScreen *screen = [aWindow screen];
            XCBSize size;
            XCBPoint position;
            XCBFrame *frame;
            XCBTitleBar *titleBar;
            TitleBarSettingsService *settingsService = [TitleBarSettingsService sharedInstance];

            uint16_t titleHgt = [settingsService heightDefined] ? [settingsService height] : [settingsService defaultHeight];

            if (maxVert)
            {
                if ([aWindow isMinimized])
                    [aWindow restoreFromIconified];

                if ([aWindow decorated])
                {
                    frame = (XCBFrame*)[aWindow parentWindow];
                    titleBar = (XCBTitleBar*)[frame childWindowForKey:TitleBar];

                    /*** frame size and position ***/
                    size = XCBMakeSize([frame windowRect].size.width, [screen height]);
                    [frame maximizeToSize:size andPosition:[frame windowRect].position];

                    /*** titlebar size and position ***/
                    size = XCBMakeSize(size.width, titleHgt);
                    position = XCBMakePoint(0.0, 0.0);
                    [titleBar maximizeToSize:size andPosition:position];
                    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

                    /*** client window size and position ***/
                    size = XCBMakeSize([aWindow windowRect].size.width - 2, [frame windowRect].size.height - titleHgt - 2); //TODO:why - 2?
                    position = XCBMakePoint(0.0, titleHgt - 1);
                    frame = nil;
                    titleBar = nil;
                }
                else
                {
                    size = XCBMakeSize([aWindow windowRect].size.width, [screen height]);
                    position = XCBMakePoint([aWindow windowRect].position.x, [aWindow windowRect].position.y);
                }

                [aWindow maximizeToSize:size andPosition:position];
                [aWindow setMaximizedVertically:maxVert];
                screen = nil;
            }

            [self updateNetWmState:aWindow];
            settingsService = nil;
        }

        /***TODO: test it ***/

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateFullscreen] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateFullscreen])
        {
            BOOL fullscr = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow isMaximized]);
            XCBScreen *screen = [aWindow screen];
            TitleBarSettingsService *settingsService = [TitleBarSettingsService sharedInstance];
            XCBFrame *frame;
            XCBTitleBar *titleBar;
            XCBSize size;
            XCBPoint position;

            uint16_t titleHgt = [settingsService heightDefined] ? [settingsService height] : [settingsService defaultHeight];

            if (fullscr)
            {
                if ([aWindow isMinimized])
                    [aWindow restoreFromIconified];

                if ([aWindow decorated])
                {
                    frame = (XCBFrame*)[aWindow parentWindow];
                    titleBar = (XCBTitleBar*)[frame childWindowForKey:TitleBar];

                    /*** frame size and position ***/
                    size = XCBMakeSize([screen width], [screen height]);
                    position = XCBMakePoint(0.0,0.0);
                    [frame maximizeToSize:size andPosition:position];

                    /*** titlebar size and position ***/
                    size = XCBMakeSize([frame windowRect].size.width, titleHgt);
                    [titleBar maximizeToSize:size andPosition:position];
                    [titleBar drawTitleBarComponentsForColor:TitleBarUpColor];

                    /*** client window size and position ***/
                    size = XCBMakeSize([frame windowRect].size.width - 2, [frame windowRect].size.height - 2);
                    position = XCBMakePoint(0, titleHgt - 1);

                    frame = nil;
                    titleBar = nil;
                }
                else
                {
                    size = XCBMakeSize([screen width], [screen height]);
                    position = XCBMakePoint(0, 0);
                }


                [aWindow maximizeToSize:size andPosition:position];
                [aWindow setFullScreen:fullscr];
                screen = nil;
            }

            [self updateNetWmState:aWindow];
            settingsService = nil;
        }

        /*** TODO: test and complete it, but shading support has really low priority ***/

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateShaded] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateShaded])
        {
            BOOL shaded = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow shaded]);

            if (shaded)
            {
                if ([aWindow isMinimized])
                    return;

                [aWindow shade];
                [aWindow setShaded:shaded];
            }

            [self updateNetWmState:aWindow];
        }

        /*** TODO: test ***/
        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateHidden] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateHidden])
        {
            BOOL minimize = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow isMinimized]);

            if (minimize)
            {
                [aWindow minimize];
                [aWindow setIsMinimized:minimize];
            }

            [self updateNetWmState:aWindow];
        }

        /*** TODO: test it. for now just focus the window and set it active ***/
        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateDemandsAttention] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateDemandsAttention])
        {
            BOOL attention = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow gotAttention]);

            if (attention)
            {
                [aWindow focus];
                [aWindow setGotAttention:attention];
            }

            [self updateNetWmState:aWindow];
        }

        if (firstProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSticky] ||
            secondProp == [atomService atomFromCachedAtomsWithKey:EWMHWMStateSticky])
        {
            BOOL always = (action == _NET_WM_STATE_ADD) || (action == _NET_WM_STATE_TOGGLE && ![aWindow alwaysOnTop]);

            if (always)
            {
                [aWindow stackAbove];
                [aWindow setAlwaysOnTop:always];
            }

            [self updateNetWmState:aWindow];
        }

    }

}

- (void) updateNetWmState:(XCBWindow*)aWindow
{
    int i = 0;
    xcb_atom_t props[12];

    if ([aWindow skipTaskBar])
    {
        NSLog(@"Skip taskbar for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipTaskbar];
    }

    if ([aWindow skipPager])
    {
        NSLog(@"Skip Pager for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateSkipPager];
    }

    if ([aWindow isAbove])
    {
        NSLog(@"Above for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateAbove];
    }

    if ([aWindow isBelow])
    {
        NSLog(@"Below for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateBelow];
    }

    if ([aWindow maximizedHorizontally])
    {
        NSLog(@"Maximize horizotally for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedHorz];
    }

    if ([aWindow maximizedVertically])
    {
        NSLog(@"Maximize vertically for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateMaximizedVert];
    }

    if ([aWindow shaded])
    {
        NSLog(@"Shaded for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateShaded];
    }

    if ([aWindow isMinimized])
    {
        NSLog(@"Hidden for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateHidden];
    }

    if ([aWindow fullScreen])
    {
        NSLog(@"Full screen for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateFullscreen];
    }

    if ([aWindow gotAttention])
    {
        NSLog(@"Demands attention for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateDemandsAttention];
    }

    if ([aWindow alwaysOnTop])
    {
        NSLog(@"Sticky for window %u", [aWindow window]);
        props[i++] = [atomService atomFromCachedAtomsWithKey:EWMHWMStateSticky];
    }

    [self changePropertiesForWindow:aWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHWMState
                           withType:XCB_ATOM_ATOM
                         withFormat:32
                     withDataLength:i
                           withData:props];
}

- (xcb_get_property_reply_t*) netWmIconFromWindow:(XCBWindow*)aWindow
{
    xcb_get_property_cookie_t cookie = xcb_get_property_unchecked([connection connection],
                                                                  false,
                                                                  [aWindow window],
                                                                  [atomService atomFromCachedAtomsWithKey:EWMHWMIcon],
                                                                  XCB_ATOM_CARDINAL,
                                                                  0,
                                                                  UINT32_MAX);

    xcb_get_property_reply_t *reply = xcb_get_property_reply([connection connection], cookie, NULL);
    return reply;
}

- (void) updateNetClientList
{

    uint32_t size = [connection clientListIndex] + 1;

    //TODO: with more screens this need to be looped ?
    XCBWindow *rootWindow = [connection rootWindowForScreenNumber:0];

    [self changePropertiesForWindow:rootWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHClientList
                           withType:XCB_ATOM_WINDOW
                         withFormat:32
                     withDataLength:size
                           withData:[connection clientList]];

    [self changePropertiesForWindow:rootWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHClientListStacking
                           withType:XCB_ATOM_WINDOW
                         withFormat:32
                     withDataLength:size
                           withData:[connection clientList]];

    rootWindow = nil;
}

- (void) updateNetActiveWindow:(XCBWindow*)aWindow
{
    XCBWindow *rootWindow = [[aWindow onScreen] rootWindow];
    xcb_window_t win = [aWindow window];

    [self changePropertiesForWindow:rootWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHActiveWindow
                           withType:XCB_ATOM_WINDOW
                         withFormat:32
                     withDataLength:1
                           withData:&win];

    NSLog(@"Active window updated %u", win);
    rootWindow = nil;
}

- (void) updateNetSupported:(NSArray*)atomsArray forRootWindow:(XCBWindow*)aRootWindow
{
    NSUInteger size = [atomsArray count];
    xcb_atom_t atomList[size];

    for (int i = 0; i < size; ++i)
        atomList[i] = [[atomsArray objectAtIndex:i] unsignedIntValue];

    [self changePropertiesForWindow:aRootWindow
                           withMode:XCB_PROP_MODE_REPLACE
                       withProperty:EWMHSupported
                           withType:XCB_ATOM_ATOM
                         withFormat:32 withDataLength:size
                           withData:atomList];
}


-(void)dealloc
{
    EWMHSupported = nil;
    EWMHClientList = nil;
    EWMHClientListStacking = nil;
    EWMHNumberOfDesktops = nil;
    EWMHDesktopGeometry = nil;
    EWMHDesktopViewport = nil;
    EWMHCurrentDesktop = nil;
    EWMHDesktopNames = nil;
    EWMHActiveWindow = nil;
    EWMHWorkarea = nil;
    EWMHSupportingWMCheck = nil;
    EWMHVirtualRoots = nil;
    EWMHDesktopLayout = nil;
    EWMHShowingDesktop = nil;

    // Root Window Messages
    EWMHCloseWindow = nil;
    EWMHMoveresizeWindow = nil;
    EWMHWMMoveresize = nil;
    EWMHRestackWindow = nil;
    EWMHRequestFrameExtents = nil;

    // Application window properties
    EWMHWMName = nil;
    EWMHWMVisibleName = nil;
    EWMHWMIconName = nil;
    EWMHWMVisibleIconName = nil;
    EWMHWMDesktop = nil;
    EWMHWMWindowType = nil;
    EWMHWMState = nil;
    EWMHWMAllowedActions = nil;
    EWMHWMStrut = nil;
    EWMHWMStrutPartial = nil;
    EWMHWMIconGeometry = nil;
    EWMHWMIcon = nil;
    EWMHWMPid = nil;
    EWMHWMHandledIcons = nil;
    EWMHWMUserTime = nil;
    EWMHWMUserTimeWindow = nil;
    EWMHWMFrameExtents = nil;

    // The window types (used with EWMH_WMWindowType)
    EWMHWMWindowTypeDesktop = nil;
    EWMHWMWindowTypeDock = nil;
    EWMHWMWindowTypeToolbar = nil;
    EWMHWMWindowTypeMenu = nil;
    EWMHWMWindowTypeUtility = nil;
    EWMHWMWindowTypeSplash = nil;
    EWMHWMWindowTypeDialog = nil;
    EWMHWMWindowTypeDropdownMenu = nil;
    EWMHWMWindowTypePopupMenu = nil;

    EWMHWMWindowTypeTooltip = nil;
    EWMHWMWindowTypeNotification = nil;
    EWMHWMWindowTypeCombo = nil;
    EWMHWMWindowTypeDnd = nil;

    EWMHWMWindowTypeNormal = nil;

    // The application window states (used with EWMH_WMWindowState)
    EWMHWMStateModal = nil;
    EWMHWMStateSticky = nil;
    EWMHWMStateMaximizedVert = nil;
    EWMHWMStateMaximizedHorz = nil;
    EWMHWMStateShaded = nil;
    EWMHWMStateSkipTaskbar = nil;
    EWMHWMStateSkipPager = nil;
    EWMHWMStateHidden = nil;
    EWMHWMStateFullscreen = nil;
    EWMHWMStateAbove = nil;
    EWMHWMStateBelow = nil;
    EWMHWMStateDemandsAttention = nil;

    // The application window allowed actions (used with EWMH_WMAllowedActions)
    EWMHWMActionMove = nil;
    EWMHWMActionResize = nil;
    EWMHWMActionMinimize = nil;
    EWMHWMActionShade = nil;
    EWMHWMActionStick = nil;
    EWMHWMActionMaximizeHorz = nil;
    EWMHWMActionMaximizeVert = nil;
    EWMHWMActionFullscreen = nil;
    EWMHWMActionChangeDesktop = nil;
    EWMHWMActionClose = nil;
    EWMHWMActionAbove = nil;
    EWMHWMActionBelow = nil;

    // Window Manager Protocols
    EWMHWMPing = nil;
    EWMHWMSyncRequest = nil;
    EWMHWMFullscreenMonitors = nil;

    // Other properties
    EWMHWMFullPlacement = nil;
    UTF8_STRING = nil;
    MANAGER = nil;
    KdeNetWFrameStrut = nil;
    MotifWMHints = nil;

    //GNUStep properties

    GNUStepMiniaturizeWindow = nil;
    GNUStepHideApp = nil;
    GNUStepFrameOffset = nil;
    GNUStepWmAttr = nil;
    GNUStepTitleBarState = nil;

    // added properties

    EWMHStartupId = nil;
    EWMHFrameExtents = nil;
    EWMHStrutPartial = nil;
    EWMHVisibleIconName = nil;

    atoms = nil;
    connection = nil;
    atomService = nil;
}

@end
