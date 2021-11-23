PACKAGE_NAME = XCBKit

include $(GNUSTEP_MAKEFILES)/common.make

VERSION = 0.0.17

FRAMEWORK_NAME = XCBKit
export FRAMEWORK_NAME

$(FRAMEWORK_NAME)_LANGUAGES = English

XCBKit_INCLUDE_DIRS = -Iservices/ -Ienums/ -Ifunctions/ -Iutils/

$(FRAMEWORK_NAME)_OBJC_FILES = \
			XCBKit.m \
			XCBConnection.m \
			XCBCursor.m \
			XCBScreen.m \
			XCBWindow.m \
			XCBVisual.m \
			XCBFrame.m \
			XCBSelection.m \
			XCBTitleBar.m \
			XCBRegion.m \
			XCBReply.m \
			XCBAttributesReply.m \
			XCBGeometryReply.m \
			XCBQueryTreeReply.m\
			XCBShape.m \
			services/EWMHService.m \
			services/XCBAtomService.m \
			services/ICCCMService.m \
			services/TitleBarSettingsService.m \
			utils/CairoDrawer.m \
			utils/CairoSurfacesSet.m \
			utils/XCBCreateWindowTypeRequest.m \
			utils/XCBWindowTypeResponse.m \
			functions/Transformers.m \
			functions/Comparators.m

$(FRAMEWORK_NAME)_HEADER_FILES = \
			XCBKit.h \
			XCBConnection.h \
			XCBCursor.h \
			XCBScreen.h \
			XCBWindow.h \
			XCBVisual.h \
			XCBFrame.h \
			XCBSelection.h \
			XCBTitleBar.h \
			XCBRegion.h \
			XCBReply.h \
			XCBAttributesReply.h \
			XCBGeometryReply.h \
			XCBQueryTreeReply.h \
			XCBShape.h \
			services/EWMHService.h \
			services/XCBAtomService.h \
			services/ICCCMService.h \
			services/TitleBarSettingsService.h \
			utils/CairoDrawer.h \
			utils/CairoSurfacesSet.h \
			utils/XCBCreateWindowTypeRequest.h \
			utils/XCBWindowTypeResponse.h \
			utils/XCBShape.h \
			functions/Transformers.h \
			functions/Comparators.h \
			enums/ETitleBarColor.h \
			enums/EXErrorMessages.h \
			enums/EIcccm.h \
			enums/EMousePosition.h \
			enums/EEwmh.h \
			protocols/server/Server.h

$(FRAMEWORK_NAME)_RESOURCE_FILES = \
			Resources/max.png \
			Resources/close.png \
			Resources/min.png

ADDITIONAL_OBJCFLAGS = -std=c99 -g -O0 -fobjc-arc -fblocks -Wall #-Wno-unused -Werror -Wall

LIBRARIES_DEPEND_UPON += $(shell pkg-config --libs xcb xcb-icccm cairo xcb-xfixes xcb-aux xcb-cursor xcb-shape) $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/framework.make
