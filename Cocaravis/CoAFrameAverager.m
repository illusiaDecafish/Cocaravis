//
//  CoAFrameAverager.m
//  Cocaravis
//
//  Created by decafish on 2019/6/29.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>
#import <Accelerate/Accelerate.h>
#import "CoABuffer.h"
#import "CoAPixelFormat.h"
#import "CoAFrameAverager.h"

static const float  valueNotReady   = -1.0f;


@interface CoAFrameAverager ()
@property (readonly) NSUInteger             sizeX;
@property (readonly) NSUInteger             sizeY;
@property (readonly) NSUInteger             totalSize;
@property (readonly) NSMutableArray         *iBuffersInUse;
@property (readonly) float                  *buffer;
@property (readonly) float                  *add;
@property (readonly) float                  *sum;
@property (readonly) float                  *result;
@property (readonly) NSUInteger             currentCount;
@property (readonly) float                  frameMaximum;
@property (readonly) double                 frameTotal;
@property (readwrite) BOOL                  opticalBlackSubtracted;


- (BOOL)resetWithFrame:(CoAImageBuffer *)imageBuffer;
- (void)swapResult;
- (void)beFreed;
- (void)calculateFrameMaximum;

@end

@implementation CoAFrameAverager


- (id)init
{
    self = [super init];
    _averagingCount = 1;
    _buffer = NULL;
    _add = NULL;
    _sum = NULL;
    _result = NULL;
    _sizeX = 0;
    _sizeY = 0;
    _totalSize = 0;
    _currentCount = 0;
    _frameMaximum = valueNotReady;
    _lastFrameMaximum = 0.0f;
    _lastImageBuffer = nil;
    _opticalBlackSubtracted = NO;
    _remainedFrameCountForOpticalBlack = 0;
    _iBuffersInUse = [[NSMutableArray alloc] initWithCapacity:256];    //  capacity value has no meaning
    
    return self;
}

- (BOOL)resetWithFrame:(CoAImageBuffer *)imageBuffer
{
    UInt32  pixelFormat = imageBuffer.pixelFormat;
    
    if (dataBitsPerSampleFromPixelFormat(pixelFormat) == 8) {
        NSUInteger  spp;
        if (colorFormatTypeFromPixelFormat(pixelFormat) == dgvColorFormatMonochrome)
            spp = 1;
        else if (colorFormatTypeFromPixelFormat(pixelFormat) == dgvColorFormatRGBA)
            spp = 4;
        else
            return NO;
        
        NSSize  size = [imageBuffer imageSize];
        _sizeX = (NSUInteger)size.width;
        _sizeY = (NSUInteger)size.height;
        _totalSize = spp * _sizeX * _sizeY;
        if (_buffer != NULL)
            free(_buffer);
        _buffer = (float *)calloc(3 * _totalSize, sizeof(float));
        _add = _buffer;
        _sum = _buffer + _totalSize;
        _result = _buffer + 2 * _totalSize;
        return YES;
    }
    return NO;
}

- (void)swapResult
{
    float   *tmp = _sum;
    _sum = _result;
    _result = tmp;
}

- (void)beFreed
{
    if (_buffer)
        free(_buffer);
    _buffer = NULL;
}

- (void)dealloc
{
    [self beFreed];
}

- (void)flushAverage
{
    _currentCount = 0;
    _remainedFrameCountForOpticalBlack = 0;
    self.opticalBlackSubtracted = NO;
    [_iBuffersInUse removeAllObjects];
    [self beFreed];
}

- (void)setNewAveragingCount:(NSUInteger)averagingCount
{
    if (averagingCount != _averagingCount) {
        _averagingCount = averagingCount;
        [self flushAverage];
    }
}

- (void)setNewImageBuffer:(CoAImageBuffer *)imageBuffer
{
    if (_buffer == NULL) {
        if (! [self resetWithFrame:imageBuffer]) {
            _lastImageBuffer = imageBuffer;
            return;
        }
    }
    
    _lastImageBuffer = imageBuffer;
    UInt8   *imageData = (UInt8 *)(imageBuffer.imageData.bytes);
    vDSP_vfltu8(imageData, 1, _add, 1, _totalSize);
    if (_remainedFrameCountForOpticalBlack > 0) {
        vDSP_vsub(_add, 1, _sum, 1, _result, 1, _totalSize);
        [self swapResult];
        _remainedFrameCountForOpticalBlack --;
        if (_remainedFrameCountForOpticalBlack == 0) {
            self.opticalBlackSubtracted = YES;
        }
    }
    else {
        vDSP_vadd(_add, 1, _sum, 1, _result, 1, _totalSize);
        [self swapResult];
        
        _currentCount ++;
        _frameMaximum = valueNotReady;
        
        [_iBuffersInUse addObject:imageBuffer];
        if (_currentCount > _averagingCount) {
            CoAImageBuffer  *oldest = [_iBuffersInUse firstObject];
            UInt8   *oldimageData = (UInt8 *)(oldest.imageData.bytes);
            vDSP_vfltu8(oldimageData, 1, _add, 1, _totalSize);
            vDSP_vsub(_add, 1, _sum, 1, _result, 1, _totalSize);
            [self swapResult];
            [_iBuffersInUse removeObject:oldest];
        }
    }
}

- (CoAImageBuffer *)averagedFrame
{
    CoAImageBuffer  *ret = nil;
    if (_buffer == NULL || _averagingCount <= 1) {
        UInt8   *imageData = (UInt8 *)(_lastImageBuffer.imageData.bytes);
        vDSP_vfltu8(imageData, 1, _result, 1, _totalSize);
        ret = _lastImageBuffer;
    }
    else {
        UInt8   *cp = (UInt8 *)malloc(_totalSize * sizeof(UInt8));
        float   mul = 1.0f / (_currentCount < _averagingCount ?  : _averagingCount);
        float   cmax = 255.0f;
        float   cmin = 0.0f;
        
        vDSP_vsmul(_sum, 1, &mul, _add, 1, _totalSize);
        vDSP_vclip(_add, 1, &cmin, &cmax, _result, 1, _totalSize);
        vDSP_vfixu8(_result, 1, cp, 1, _totalSize);
        NSData  *data = [[NSData alloc] initWithBytesNoCopy:cp length:_totalSize * sizeof(UInt8) freeWhenDone:YES];
        ret = [[CoAImageBuffer alloc] initWithImageBuffer:_iBuffersInUse.lastObject withFrameDataNoCopy:data];
    }
    return ret;
}


- (void)startToTakeOpticalBlack
{
    [self flushAverage];
    self.opticalBlackSubtracted = NO;
    _remainedFrameCountForOpticalBlack = _averagingCount;
}

- (void)calculateFrameMaximum
{
    float   max = 0.0f;
    
    vDSP_maxv(_result + _sizeX, 1, &max, _totalSize - _sizeX);
    if (max > 0.0f) {
        _frameMaximum = max / _averagingCount;
        _lastFrameMaximum = _frameMaximum * _averagingCount;
    }
}


@end


