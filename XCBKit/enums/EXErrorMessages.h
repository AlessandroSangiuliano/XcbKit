//
//  EXErrorMessages.h
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 26/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, ErrorMessage)
{
    BadRequest = 1,
    BadValue,
    BadWindow,
    BadPixmap,
    BadAtom,
    BadCursor,
    BadFont,
    BadMatch,
    BadDrawable,
    BadAccess,
    BadAlloc,
    BadColor,
    BadGC,
    BadIDChoice,
    BadName,
    BadLength,
    BadImplementation
};
