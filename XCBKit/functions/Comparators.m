//
// Created by slex on 09/04/21.
//

#include "Comparators.h"


BOOL CmXCBColorAreEquals(XCBColor fColor, XCBColor sColor)
{
    BOOL equals = NO;

    if (fColor.alphaComponent == sColor.alphaComponent &&
        fColor.blueComponent == sColor.blueComponent &&
        fColor.greenComponent == sColor.greenComponent &&
        fColor.redComponent == sColor.redComponent)
    {
        equals = YES;
    }

    return equals;
}
