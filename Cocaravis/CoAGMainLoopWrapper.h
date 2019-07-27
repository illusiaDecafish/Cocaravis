//
//  CoAGMainLoopWrapper.h
//  Cocaravis
//
//  Created by decafish on 2019/7/08.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

extern NSString *newBufferSignalName;
extern NSString *controlLostSignalName;

@class CoABuffer;
@class CoAStream;

//  this class creates one thread holding gMainLoop
//  to avoide g_main_loop_run() to block.
//  Is there any other simple solution?

@interface CoAGMainLoopWrapper : NSObject

+ (CoAGMainLoopWrapper *)sharedMainLoopWrapper;

@end

NS_ASSUME_NONNULL_END
