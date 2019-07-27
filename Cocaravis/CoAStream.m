//
//  CoAStream.m
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>
#include <signal.h>
#import "CoAStream.h"
#import "CoACamera.h"
#import "CoADevice.h"
#import "CoABuffer.h"
#import "CoAGMainLoopWrapper.h"

static const char   *newBufferSignalNotification    = "new-buffer";

static void         newBufferCallback(ArvStream *stream, void *data);
void    streamCallback(void *user_data,
                       ArvStreamCallbackType type,
                       ArvBuffer *buffer);

@interface CoAStream ()
@property (readonly, weak) CoACamera    *camera;
@property (readonly, weak) CoADevice    *device;
@property (readonly) NSUInteger         bufferCount;
@property (readwrite) ArvStream         *stream;
@property (readwrite) BOOL              isRunning;
@property (readwrite) guint64           lastTimeStamp;
@property (readwrite) NSInteger         completedBufferCount;
@property (readwrite) NSInteger         failureCount;
@property (readwrite) NSInteger         underrunCount;
@property (readwrite) NSInteger         underrunDifference;

- (void)receiveNewBuffer:(ArvBuffer *)arvBuffer;

@end

@implementation CoAStream

- (instancetype)initWithCamera:(CoACamera *)camera
              pooledBufferSize:(NSUInteger)payloadSize
                         Count:(NSUInteger)count
{
    self = [super init];
    _receiver = nil;
    _camera = camera;
    _frameAverager = nil;
    _payloadSize = payloadSize;
    _bufferCount = count;
    _completedBufferCount = 0;
    _failureCount = 0;
    _underrunCount = 0;
    _underrunDifference = 0;
    _lastTimeStamp = -1;
    _stream = arv_camera_create_stream(camera.arvCameraObject, NULL, NULL);
    //_stream = arv_device_create_stream(device.arvDeviceObject, streamCallback, (void *)CFBridgingRetain(self));
    if (_stream == NULL)
        return nil;


    gulong  handlerNewBuffer = g_signal_connect(_stream, newBufferSignalNotification, G_CALLBACK(newBufferCallback), (void *)CFBridgingRetain(self));
    if (handlerNewBuffer == 0)
        fprintf(stderr, "can not set g_signal for newBuffer");
    arv_stream_set_emit_signals(self.stream, true);
    
    for (NSInteger i = 0 ; i < self.bufferCount ; i ++)
        arv_stream_push_buffer(_stream, arv_buffer_new(_payloadSize, NULL));

     CFBridgingRelease((__bridge const void *)self);

    _isRunning = YES;
    
    //  start GMainLoop
    [CoAGMainLoopWrapper sharedMainLoopWrapper];

    static const NSTimeInterval     statisticCheckInterval      = 1.0;
    static const NSInteger          underrunDiffernceThreashold = 3;
    static const NSInteger          underrunMaxCountThreashold  = 10;
    [NSTimer scheduledTimerWithTimeInterval:statisticCheckInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (self.isRunning) {
            guint64 complete;
            guint64 failure;
            guint64 underrun;
            
            //      is function arv_stream_get_statistics() thread-safe?
            arv_stream_get_statistics(self.stream, &complete, &failure, &underrun);
            
            self.completedBufferCount = complete;
            self.failureCount = failure;
            self.underrunDifference = underrun - self.underrunCount;
            self.underrunCount = underrun;
            if (underrun > 0)
                NSLog(@"underrun = %ld", underrun);
            if (self.receiver != nil) {
                if ([self.receiver respondsToSelector:@selector(stream:detectTooManyUnderrunCount:)]
                    && (self.underrunDifference > underrunDiffernceThreashold) //  check occurence rate
                    && (self.underrunCount > underrunMaxCountThreashold)) {
                    [self.receiver stream:self detectTooManyUnderrunCount:[NSNumber numberWithInteger:self.underrunCount]];
                }
                if ([self.receiver respondsToSelector:@selector(streamRefreshingStatistics:)])
                    [self.receiver streamRefreshingStatistics:self];
            }
        }
        else
            [timer invalidate];
    }];
    return self;
}

- (void)receiveNewBuffer:(ArvBuffer *)arvBuffer
{
    CoABuffer   *tmpBuf = [CoABuffer bufferWithArvBuffer:arvBuffer];
    CoABuffer    *cbuf = tmpBuf;
    if ((cbuf.payloadType == CoABufferPayloadTypeImage) && (self.frameAverager != nil)) {
        [self.frameAverager setNewImageBuffer:(CoAImageBuffer *)tmpBuf];
        cbuf = [self.frameAverager averagedFrame];
    }
    if ((self.receiver != nil) && ([self.receiver respondsToSelector:@selector(stream:receiveBuffer:)])) {
        [self.receiver stream:self receiveBuffer:cbuf];
    }
    
    //  calculate real frame rate
    guint64 timeStamp = arv_buffer_get_timestamp(arvBuffer);
    if (self.lastTimeStamp > 0) {
        double  interval = 0.001 * 0.001 * 0.001 * (timeStamp - self.lastTimeStamp);
        if (interval != 0.0)
            _currentFrameRate = 1.0 / interval;
    }
    _lastTimeStamp = timeStamp;
    
    if (! self.isRunning) {
        arv_stream_set_emit_signals(self.stream, NO);
        g_object_unref(self.stream);
    }
}

- (void)stopStream
{
    self.isRunning = NO;
}


- (void)attachFrameAverager
{
    _frameAverager = [[CoAFrameAverager alloc] init];
}

@end



static void newBufferCallback(ArvStream *stream, void *data)
{
    ArvBuffer *buffer;
    buffer = arv_stream_try_pop_buffer(stream);
    if (buffer != NULL) {
        if (arv_buffer_get_status(buffer) == ARV_BUFFER_STATUS_SUCCESS) {
            CoAStream   *selfptr = (__bridge CoAStream *)data;
            [selfptr receiveNewBuffer:buffer];
        }
    }
    arv_stream_push_buffer(stream, buffer);
}

void    streamCallback(void *user_data,
                       ArvStreamCallbackType type,
                       ArvBuffer *buffer)
{
    if (type == ARV_STREAM_CALLBACK_TYPE_BUFFER_DONE) {
        //guint32    fid = arv_buffer_get_frame_id (buffer);
        //printf("\tcallback called for %d\n", fid);
        ArvBuffer *buffer;
        CoAStream *stream = (__bridge CoAStream *)user_data;
        ArvStream *arvStream = stream.stream;
        buffer = arv_stream_try_pop_buffer(arvStream);
        if (buffer != NULL) {
            if (arv_buffer_get_status(buffer) == ARV_BUFFER_STATUS_SUCCESS) {
                [stream receiveNewBuffer:buffer];
            }
        }
        arv_stream_push_buffer (arvStream, buffer);
    }
}
