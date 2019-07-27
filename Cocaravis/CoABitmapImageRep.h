//
//  CoABitmapImageRep.h
//  Cocaravis
//
//  Created by decafish on 2019/7/21.
//  Copyright illusia decafish. All rights reserved.
//

#import <Cocoa/Cocoa.h>

/*
    CoABitmapImageRep for converting CoAImageBuffer to draw in a NSView object
    All mathods only for 8-bit resolution in the current version
 */

NS_ASSUME_NONNULL_BEGIN



@class CoAImageBuffer;

@interface CoABitmapImageRep : NSBitmapImageRep

+ (instancetype)imageRepWithImageBuffer:(CoAImageBuffer *)imageBuffer;

//  speudo-colored image rep for Mono8 pixel format type
//  scaling argument:   sample value = scaling * pixel value, for 1 < scaling < 4
- (instancetype)initPseudoColoredImageWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer withScaling:(double)scaling;
- (instancetype)initPseudoColoredImageWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer;

//  shrinked to half (quarter area) imagerep to display in a small window ballancing between performance and resolution.
- (instancetype)initWithShrinkedRGBAImageWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer;
- (instancetype)initWithShrinkedRGBAImageWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer
                                                whiteBalanceR:(float)r G:(float)g B:(float)b;
@end

NS_ASSUME_NONNULL_END
