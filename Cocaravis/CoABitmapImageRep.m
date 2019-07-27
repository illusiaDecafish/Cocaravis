//
//  CoABitmapImageRep.m
//  Cocaravis
//
//  Created by decafish on 2019/7/21.
//  Copyright illusia decafish. All rights reserved.
//

#include <string.h>

#import "CoABuffer.h"
#import "CoAPixelFormat.h"
#import "CoABitmapImageRep.h"


//  gamma = 2 conversion table for 8bits/sample
static UInt8    gamma2Table[]={0, 1, 3, 5, 7, 9, 11, 13, 14, 16, 18, 20, 22, 24, 25, 27, 29, 31,
    32, 34, 36, 38, 39, 41, 43, 45, 46, 48, 50, 51, 53, 55, 56, 58, 60,
    61, 63, 65, 66, 68, 70, 71, 73, 74, 76, 78, 79, 81, 82, 84, 85, 87,
    88, 90, 91, 93, 95, 96, 97, 99, 100, 102, 103, 105, 106, 108, 109,
    111, 112, 113, 115, 116, 118, 119, 120, 122, 123, 124, 126, 127, 128,
    130, 131, 132, 134, 135, 136, 138, 139, 140, 141, 143, 144, 145, 146,
    148, 149, 150, 151, 153, 154, 155, 156, 157, 158, 160, 161, 162, 163,
    164, 165, 166, 168, 169, 170, 171, 172, 173, 174, 175, 176, 177, 178,
    179, 180, 181, 182, 183, 184, 185, 186, 187, 188, 189, 190, 191, 192,
    193, 194, 195, 196, 197, 198, 199, 199, 200, 201, 202, 203, 204, 205,
    205, 206, 207, 208, 209, 210, 210, 211, 212, 213, 213, 214, 215, 216,
    216, 217, 218, 219, 219, 220, 221, 221, 222, 223, 223, 224, 225, 225,
    226, 227, 227, 228, 229, 229, 230, 230, 231, 232, 232, 233, 233, 234,
    234, 235, 235, 236, 236, 237, 237, 238, 238, 239, 239, 240, 240, 241,
    241, 242, 242, 243, 243, 243, 244, 244, 245, 245, 245, 246, 246, 246,
    247, 247, 247, 248, 248, 248, 249, 249, 249, 250, 250, 250, 250, 251,
    251, 251, 251, 252, 252, 252, 252, 252, 253, 253, 253, 253, 253, 253,
    254, 254, 254, 254, 254, 254, 254, 255};

static UInt8    clip(float x);


@interface CoABitmapImageRep ()
- (instancetype)initWithImageBuffer:(CoAImageBuffer *)imageBuffer
                         colorSpace:(NSColorSpaceName)colorSpaceName
                     samplesPerPxiel:(NSUInteger)spp
                           hasAlpha:(BOOL)alpha;
- (instancetype)initWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer;
- (instancetype)initWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer;
- (instancetype)initWithRGBImageBuffer:(CoAImageBuffer *)imageBuffer samplesPerPixel:(NSInteger)spp;

- (void)convertBayerImageBuffer:(CoAImageBuffer *)imageBuffer
toShrinkedRGBAWithWhiteBaranceR:(float)wr
                              G:(float)wg
                              B:(float)wb;

- (void)fillRainbowColoringForMonochrome:(UInt8 *)bitmaps withStepRatio:(float)ratio;


@end

@implementation CoABitmapImageRep

+ (instancetype)imageRepWithImageBuffer:(CoAImageBuffer *)imageBuffer
{
    if (colorFormatTypeFromPixelFormat(imageBuffer.pixelFormat) == dgvColorFormatMonochrome)
        return [[CoABitmapImageRep alloc] initWithMonochromeImageBuffer:imageBuffer];
    else if (colorFormatTypeFromPixelFormat(imageBuffer.pixelFormat) == dgvColorFormatBayer)
        return [[CoABitmapImageRep alloc] initWithBayerImageBuffer:imageBuffer];
    else if (colorFormatTypeFromPixelFormat(imageBuffer.pixelFormat) == dgvColorFormatRGB)
        return [[CoABitmapImageRep alloc] initWithRGBImageBuffer:imageBuffer samplesPerPixel:3];
    else if (colorFormatTypeFromPixelFormat(imageBuffer.pixelFormat) == dgvColorFormatRGBA)
        return [[CoABitmapImageRep alloc] initWithRGBImageBuffer:imageBuffer samplesPerPixel:4];
    return nil;
}

- (instancetype)initWithImageBuffer:(CoAImageBuffer *)imageBuffer
                         colorSpace:(NSColorSpaceName)colorSpaceName
                    samplesPerPxiel:(NSUInteger)spp
                           hasAlpha:(BOOL)alpha
{
    NSInteger   width = (NSInteger)(imageBuffer.imageSize.width);
    return [super initWithBitmapDataPlanes:NULL
                                pixelsWide:width
                                pixelsHigh:(NSInteger)(imageBuffer.imageSize.height)
                             bitsPerSample:8
                           samplesPerPixel:spp
                                  hasAlpha:alpha
                                  isPlanar:NO
                            colorSpaceName:colorSpaceName
                               bytesPerRow:spp * width
                              bitsPerPixel:0];
}

- (instancetype)initWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer
{
    self = [self initWithImageBuffer:imageBuffer
                          colorSpace:NSCalibratedWhiteColorSpace
                     samplesPerPxiel:1
                            hasAlpha:NO];
    memcpy(self.bitmapData, imageBuffer.rawImageBytes, self.pixelsWide * self.pixelsHigh);
    return self;
}

- (instancetype)initPseudoColoredImageWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer withScaling:(double)scaling
{
    if (colorFormatTypeFromPixelFormat(imageBuffer.pixelFormat) != dgvColorFormatMonochrome)
        return nil;
    self = [self initWithImageBuffer:imageBuffer
                          colorSpace:NSCalibratedRGBColorSpace
                     samplesPerPxiel:4
                            hasAlpha:YES];
    [self fillRainbowColoringForMonochrome:imageBuffer.rawImageBytes withStepRatio:(float)scaling];
    return self;
}

- (instancetype)initPseudoColoredImageWithMonochromeImageBuffer:(CoAImageBuffer *)imageBuffer
{
    return [self initPseudoColoredImageWithMonochromeImageBuffer:imageBuffer withScaling:1.0];
}

- (instancetype)initWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer
{
    //  will be implemented
    return [self initWithShrinkedRGBAImageWithBayerImageBuffer:imageBuffer];
}

- (instancetype)initWithRGBImageBuffer:(CoAImageBuffer *)imageBuffer samplesPerPixel:(NSInteger)spp
{
    self = [self initWithImageBuffer:imageBuffer
                          colorSpace:NSDeviceRGBColorSpace
                     samplesPerPxiel:spp
                            hasAlpha:(spp > 3)];
    memcpy(self.bitmapData, imageBuffer.rawImageBytes, spp * self.pixelsWide * self.pixelsHigh);
    return self;
}

- (instancetype)initWithShrinkedRGBAImageWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer
{
    return [self initWithShrinkedRGBAImageWithBayerImageBuffer:imageBuffer
                                                 whiteBalanceR:1.0f
                                                             G:1.0f
                                                             B:1.0f];
}
- (instancetype)initWithShrinkedRGBAImageWithBayerImageBuffer:(CoAImageBuffer *)imageBuffer
                                                whiteBalanceR:(float)r G:(float)g B:(float)b
{
    NSInteger   width = (NSInteger)(imageBuffer.imageSize.width * 0.5);
    NSInteger   height = (NSInteger)(imageBuffer.imageSize.height * 0.5);
    self = [super initWithBitmapDataPlanes:NULL
                                pixelsWide:width
                                pixelsHigh:height
                             bitsPerSample:8
                           samplesPerPixel:4
                                  hasAlpha:YES
                                  isPlanar:NO
                            colorSpaceName:NSDeviceRGBColorSpace
                               bytesPerRow:width * 4
                              bitsPerPixel:0];
    [self convertBayerImageBuffer:imageBuffer
  toShrinkedRGBAWithWhiteBaranceR:r
                                G:g
                                B:b];
    return self;
}



- (void)convertBayerImageBuffer:(CoAImageBuffer *)imageBuffer
toShrinkedRGBAWithWhiteBaranceR:(float)wr
                              G:(float)wg
                              B:(float)wb
{
    static NSUInteger   r = 0;
    static NSUInteger   g = 1;
    static NSUInteger   b = 2;
    static NSUInteger   a = 3;
    static NSUInteger   spp = 4;
    static UInt8        alphaValue = 0xFF;
    
    float   min = wr;
    if (wg < min)
        min = wg;
    if (wb < min)
        min = wb;
    if (min != 0.0f) {
        wr /= min;
        wg /= min;
        wb /= min;
    }
    
    NSUInteger          sizeX = (NSInteger)(imageBuffer.imageSize.width);
    NSUInteger          xend = sizeX / 2;
    NSUInteger          sizeY = (NSInteger)(imageBuffer.imageSize.height);
    NSUInteger          yend = sizeY / 2;
    UInt8               *bayer = (UInt8 *)(imageBuffer.rawImageBytes);
    UInt8               *rgbPlane = (UInt8 *)(self.bitmapData);
    for (NSUInteger y = 0 ; y < yend ; y ++) {
        UInt8   *bp = bayer + 2 * sizeX * y;
        for (NSUInteger x = 0 ; x < xend ; x++) {
            UInt8   rr = *(bp + 1);
            UInt8   gg = ((UInt16)(*bp) + *(bp + sizeX + 1)) / 2;
            UInt8   bb = *(bp + sizeX);
            rgbPlane[r] = clip(rr * wr);
            rgbPlane[g] = clip(gg * wg);
            rgbPlane[b] = clip(bb * wb);
            rgbPlane[a] = alphaValue;
            rgbPlane += spp;
            bp += 2;
        }
    }
}

- (void)fillRainbowColoringForMonochrome:(UInt8 *)bitmaps withStepRatio:(float)ratio
{
    if (ratio <= 1.0f)
        ratio = 1.0f;
    else if (ratio > 4.0f)
        ratio = 4.0f;
    NSInteger   sizeX = self.pixelsWide;
    UInt8       *colp = self.bitmapData;
    for (NSInteger h = 0 ; h < self.pixelsHigh ; h ++) {
        UInt8   *rp = bitmaps + h * sizeX;
        for (NSInteger w = 0 ; w < sizeX ; w ++) {
            UInt8   mag = (UInt8)((*(rp ++)) * ratio);
            UInt8   val = gamma2Table[mag];
            
            if (val < 64) {
                *(colp ++) = 0;
                *(colp ++) = (val * 4);
                *(colp ++) = 255;
            }
            else if (val < 128) {
                *(colp ++) = 0;
                *(colp ++) = 255;
                *(colp ++) = (255 - (val - 64) * 4);
            }
            else if (val < 192) {
                *(colp ++) = ((val - 128) * 4);
                *(colp ++) = 255;
                *(colp ++) = 0;
            }
            else if (val < 255) {
                *(colp ++) = 255;
                *(colp ++) = (255 - (val - 192) * 4);
                *(colp ++) = 0;
            }
            else {
                *(colp ++) = 255;
                *(colp ++) = 255;
                *(colp ++) = 255;
            }
            *(colp ++) = 255;
        }
    }
}


@end

static UInt8    clip(float x)
{
    if (x >= 255.0f)
        return 255;
    return (UInt8)x;
}
