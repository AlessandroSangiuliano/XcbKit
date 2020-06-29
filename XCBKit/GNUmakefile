PACKAGE_NAME = XCBKit

include $(GNUSTEP_MAKEFILES)/common.make

VERSION = 0.0.9

FRAMEWORK_NAME = XCBKit
export FRAMEWORK_NAME

$(FRAMEWORK_NAME)_LANGUAGES = English

XCBKit_INCLUDE_DIRS = -Iservices/ -Ienums/ -Ifunctions/ -Iutils/

$(FRAMEWORK_NAME)_OBJC_FILES = \
			XCBKit.m \
			XCBConnection.m \
			XCBScreen.m \
			XCBWindow.m \
			XCBVisual.m \
			XCBFrame.m \
			XCBSelection.m \
			XCBTitleBar.m \
			XCBRegion.m \
			services/EWMHService.m \
			services/XCBAtomService.m \
			services/ICCCMService.m \
			utils/CairoDrawer.m \
			utils/XCBCreateWindowTypeRequest.m \
			utils/XCBWindowTypeResponse.m \
			functions/Transformers.m

$(FRAMEWORK_NAME)_HEADER_FILES = \
		  XCBKit.h \
			XCBConnection.h \
			XCBScreen.h \
			XCBWindow.h \
			XCBVisual.h \
			XCBFrame.h \
			XCBSelection.h \
			XCBTitleBar.h \
			XCBRegion.h \
			services/EWMHService.h \
			services/XCBAtomService.h \
			services/ICCCMService.h \
			utils/CairoDrawer.h \
			utils/XCBCreateWindowTypeRequest.h \
			utils/XCBWindowTypeResponse.h \
			utils/XCBShape.h \
			functions/Transformers.h \
			enums/EMessage.h \
			enums/ETitleBarColor.h

ADDITIONAL_OBJCFLAGS = -std=c99 -g -O0 -fobjc-arc #-Wno-unused -Werror -Wall

LIBRARIES_DEPEND_UPON += $(shell pkg-config --libs xcb xcb-icccm cairo xcb-xfixes) $(FND_LIBS) $(OBJC_LIBS) $(SYSTEM_LIBS)

include $(GNUSTEP_MAKEFILES)/aggregate.make
include $(GNUSTEP_MAKEFILES)/framework.make