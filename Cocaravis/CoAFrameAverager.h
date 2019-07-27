//
//  CoAFrameAverager.h
//  Cocaravis
//
//  Created by decafish on 2019/6/29.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    CoAFrameAverager class, accumulate multi frames to suppress random noises on a image
    to use the class, call
    - (void)attachFrameAverager;
    method  of CoAStream and
    frameAverager property.
 
    CoAFrameAverager object accumulates over number of 'averagingCount' frames by sliding window method for temporal direction
    and no degredation of resolution for spacial directions
    'lastImageBuffer' property holds averaged frame.
    'lastFrameMaximum' property holds maximum pixel value of averaged frame
    'flushAverage' method restarts accumulation.

    About optical black subtraction
    for light intensity distribution measurement using camera
    cover lens optically, start subtraction, then after 'averagingCount' + 1 frames are
    subtracted covered frames by software.
    optical black subtraction is enabled only
        - 'averagingCount' > 1
        - for monochrome image format of CoAImageBuffer
    If gamma value is not equal to 1 or not uncompressed,
    optical black subtraction should not be on.
*/

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, dgvNormalizationStyles) {
    dgvNormalizationStyleNothing = 0,
    dgvNormalizationStyleCount,
    dgvNormalizationStyleFrameMaximum,
    dgvNormalizationStyleLSFMaximum
};

@class CoAImageBuffer;
@class CoALineSpreadFunction;
@protocol CoALSFReceiverProtocol;


@interface CoAFrameAverager : NSObject


@property (readonly) NSUInteger                 averagingCount;
@property (readonly) CoAImageBuffer             *lastImageBuffer;

@property (readonly) float                      lastFrameMaximum;
@property (readonly) BOOL                       opticalBlackSubtracted;
@property (readonly) NSUInteger                 remainedFrameCountForOpticalBlack;

- (void)flushAverage;
- (void)setNewAveragingCount:(NSUInteger)averagingCount;

- (void)setNewImageBuffer:(CoAImageBuffer *)imageBuffer;
- (CoAImageBuffer *)averagedFrame;

- (void)startToTakeOpticalBlack;


@end

NS_ASSUME_NONNULL_END
