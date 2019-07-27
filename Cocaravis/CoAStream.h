//
//  CoAStream.h
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoAFrameAverager.h"

/*
    CoAStream class, a wrapper of ArvStream
    callbacks for receiving stream buffers are replaced by
    delegete messages under CoAStreamReceiveProtocol protocol
 */

NS_ASSUME_NONNULL_BEGIN

@class CoAStream;
@class CoABuffer;


//  receiver object should adopt the protocol below
//  and set itself to receiver property of the CoAStream object

@protocol CoAStreamReceiveProtocol <NSObject>

- (void)stream:(CoAStream *)stream receiveBuffer:(CoABuffer *)buffer;

@optional
- (void)stream:(CoAStream *)stream detectTooManyUnderrunCount:(NSNumber *)count;
- (void)controlLostWithStream:(CoAStream *)stream;

- (void)streamRefreshingStatistics:(CoAStream *)stream;
@end

@class CoACamera;
@class CoADevice;

@interface CoAStream : NSObject
@property (readonly) ArvStream                              *stream;
@property (readwrite) NSString                              *name;
@property (readonly) NSUInteger                             payloadSize;
@property (readwrite, weak) id <CoAStreamReceiveProtocol>   receiver;
@property (readonly) double                                 currentFrameRate;
@property (readonly) NSInteger                              completedBufferCount;
@property (readonly) NSInteger                              failureCount;
@property (readonly) NSInteger                              underrunCount;
@property (readonly) CoAFrameAverager                       *frameAverager;

- (instancetype)initWithCamera:(CoACamera *)camera
              pooledBufferSize:(NSUInteger)payloadSize
                         Count:(NSUInteger)count;

- (void)attachFrameAverager;

- (void)stopStream;

@end

NS_ASSUME_NONNULL_END
