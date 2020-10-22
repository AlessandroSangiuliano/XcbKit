//
//  XCBReply.m
//  XCBKit
//
//  Created by Alessandro Sangiuliano on 26/07/20.
//  Copyright (c) 2020 alex. All rights reserved.
//

#import "XCBReply.h"

@implementation XCBReply

@synthesize isError;
@synthesize message;
@synthesize reply;
@synthesize error;

- (id) initWithError:(xcb_generic_error_t *)anError
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    isError = YES;
    
    message = anError->error_code;
    error = anError;
    
    return self;
}

- (id) initWithReply:(void *)aReply
{
    self = [super init];
    
    if (self == nil)
    {
        NSLog(@"Unable to init...");
        return nil;
    }
    
    reply = aReply;
    
    return self;
}

- (void) description
{
    NSString *errorMessage;
    
    if (isError)
    {
        switch (message)
        {
            case BadRequest:
                errorMessage = @"BadRequest";
                break;
            case BadValue:
                errorMessage = @"BadValue";
                break;
            case BadWindow:
                errorMessage = @"BadWindow";
                break;
            case BadPixmap:
                errorMessage = @"BadPixmap";
                break;
            case BadAtom:
                errorMessage = @"BadAtom";
                break;
            case BadCursor:
                errorMessage = @"BadCursor";
                break;
            case BadFont:
                errorMessage = @"BadFont";
                break;
            case BadMatch:
                errorMessage = @"BadMatch";
                break;
            case BadDrawable:
                errorMessage = @"BadDreawable";
                break;
            case BadAccess:
                errorMessage = @"BadAccess";
                break;
            case BadAlloc:
                errorMessage = @"BadAlloc";
                break;
            case BadColor:
                errorMessage = @"BadColor";
                break;
            case BadGC:
                errorMessage = @"BadGC";
                break;
            case BadIDChoice:
                errorMessage = @"BadIDChoice";
                break;
            case BadName:
                errorMessage = @"BadName";
                break;
            case BadLength:
                errorMessage = @"BadLength";
                break;
            case BadImplementation:
                errorMessage = @"BadImplementation";
                break;
                
            default:
                break;
        }
        NSLog(@"Error: %@", errorMessage);
    }
    
    if (!isError)
        NSLog(@"Reply address: %d", (int)&reply);
    
}

- (void) dealloc
{
    if (reply)
        free(reply);
    
    reply = NULL;
    
    
    if (error)
        free(error);
    
    error = NULL;
    
}

@end
