//
//  CoAGMainLoopWrapper.m
//  Cocaravis
//
//  Created by decafish on 2019/7/08.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>
#include <signal.h>
#import "CoAGMainLoopWrapper.h"

static CoAGMainLoopWrapper  *gMainLoop = nil;

@interface CoAGMainLoopWrapper ()
@property (readonly) GMainLoop          *gMainLoop;

- (void)loopBody:(id)obj;

@end


@implementation CoAGMainLoopWrapper

//  CoAGaimLoopWrapper object is a simple singleton

+ (CoAGMainLoopWrapper *)sharedMainLoopWrapper
{
    if (gMainLoop == nil) {
        gMainLoop = [[CoAGMainLoopWrapper alloc] init];
    }
    return gMainLoop;
}


- (instancetype)init
{
    if (gMainLoop != nil)
        return gMainLoop;

    self = [super init];
    [NSThread detachNewThreadSelector:@selector(loopBody:) toTarget:self withObject:nil];
    return self;
}

- (void)loopBody:(id)obj
{
    _gMainLoop = g_main_loop_new(NULL, false);
    g_main_loop_run(self.gMainLoop);
    g_main_loop_unref(self.gMainLoop);
}

- (void)dealloc
{
    g_main_loop_quit(self.gMainLoop);
}


@end
