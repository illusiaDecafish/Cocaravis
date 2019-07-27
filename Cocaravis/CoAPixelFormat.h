//
//  CoAPixelFormat.h
//  GigECamera
//
//  Created by decafish on 2015/02/27.
//  Copyright (c) 2015 decafish. All rights reserved.
//

#import <Foundation/Foundation.h>


//  copied from very old file for IIDC cameras

extern const UInt32     GVSP_PIX_MONO;
extern const UInt32     GVSP_PIX_RGB; // deprecated in version 1.1
extern const UInt32     GVSP_PIX_COLOR;
extern const UInt32     GVSP_PIX_CUSTOM;
extern const UInt32     GVSP_PIX_COLOR_MASK;

extern const UInt32     GVSP_PIX_OCCUPY8BIT;
extern const UInt32     GVSP_PIX_OCCUPY12BIT;
extern const UInt32     GVSP_PIX_OCCUPY16BIT;
extern const UInt32     GVSP_PIX_OCCUPY24BIT;
extern const UInt32     GVSP_PIX_OCCUPY32BIT;
extern const UInt32     GVSP_PIX_OCCUPY36BIT;
extern const UInt32     GVSP_PIX_OCCUPY48BIT;
extern const UInt32     GVSP_PIX_EFFECTIVE_PIXEL_SIZE_MASK;
extern const UInt32     GVSP_PIX_EFFECTIVE_PIXEL_SIZE_SHIFT;

extern const UInt32     GVSP_PIX_ID_MASK;

extern const UInt32     GVSP_PIX_MONO8;
extern const UInt32     GVSP_PIX_MONO8_SIGNED;
extern const UInt32     GVSP_PIX_MONO10;
extern const UInt32     GVSP_PIX_MONO10_PACKED;
extern const UInt32     GVSP_PIX_MONO12;
extern const UInt32     GVSP_PIX_MONO12_PACKED;
extern const UInt32     GVSP_PIX_MONO14;
extern const UInt32     GVSP_PIX_MONO16;

extern const UInt32     GVSP_PIX_BAYGR8;
extern const UInt32     GVSP_PIX_BAYRG8;
extern const UInt32     GVSP_PIX_BAYGB8;
extern const UInt32     GVSP_PIX_BAYBG8;
extern const UInt32     GVSP_PIX_BAYGR10;
extern const UInt32     GVSP_PIX_BAYRG10;
extern const UInt32     GVSP_PIX_BAYGB10;
extern const UInt32     GVSP_PIX_BAYBG10;
extern const UInt32     GVSP_PIX_BAYGR12;
extern const UInt32     GVSP_PIX_BAYRG12;
extern const UInt32     GVSP_PIX_BAYGB12;
extern const UInt32     GVSP_PIX_BAYBG12;

extern const UInt32     GVSP_PIX_BAYGR10_PACKED;
extern const UInt32     GVSP_PIX_BAYRG10_PACKED;
extern const UInt32     GVSP_PIX_BAYGB10_PACKED;
extern const UInt32     GVSP_PIX_BAYBG10_PACKED;
extern const UInt32     GVSP_PIX_BAYGR12_PACKED;
extern const UInt32     GVSP_PIX_BAYRG12_PACKED;
extern const UInt32     GVSP_PIX_BAYGB12_PACKED;
extern const UInt32     GVSP_PIX_BAYBG12_PACKED;
extern const UInt32     GVSP_PIX_BAYGR16;
extern const UInt32     GVSP_PIX_BAYRG16;
extern const UInt32     GVSP_PIX_BAYGB16;
extern const UInt32     GVSP_PIX_BAYBG16;

extern const UInt32     GVSP_PIX_RGB8_PACKED;
extern const UInt32     GVSP_PIX_BGR8_PACKED;
extern const UInt32     GVSP_PIX_RGBA8_PACKED;
extern const UInt32     GVSP_PIX_BGRA8_PACKED;
extern const UInt32     GVSP_PIX_RGB10_PACKED;
extern const UInt32     GVSP_PIX_BGR10_PACKED;
extern const UInt32     GVSP_PIX_RGB12_PACKED;
extern const UInt32     GVSP_PIX_BGR12_PACKED;
extern const UInt32     GVSP_PIX_RGB16_PACKED;
extern const UInt32     GVSP_PIX_RGB10V1_PACKED;
extern const UInt32     GVSP_PIX_RGB10V2_PACKED;
extern const UInt32     GVSP_PIX_RGB12V1_PACKED;

extern const UInt32     GVSP_PIX_YUV411_PACKED;
extern const UInt32     GVSP_PIX_YUV422_PACKED;
extern const UInt32     GVSP_PIX_YUV422_YUYV_PACKED;
extern const UInt32     GVSP_PIX_YUV444_PACKED;

extern const UInt32     GVSP_PIX_RGB8_PLANAR;
extern const UInt32     GVSP_PIX_RGB10_PLANAR;
extern const UInt32     GVSP_PIX_RGB12_PLANAR;
extern const UInt32     GVSP_PIX_RGB16_PLANAR;

typedef NS_ENUM(NSInteger, CoAColorFormatType) {
    dgvColorFormatMonochrome = 1,
    dgvColorFormatSignedMonochrome,
    dgvColorFormatBayer,
    dgvColorFormatRGB,
    dgvColorFormatRGBA,
    dgvColorFormatPlanerRGB,
    dgvColorFormatYUV,
    dgvColorFormatOther
};

extern CoAColorFormatType   colorFormatTypeFromPixelFormat(UInt32 pixelFormatValue);

typedef NS_ENUM(NSInteger, CoABayerFormatType) {
    dgvBayerFormatNotBayer = 0,
    dgvBayerFormatBayerGR,
    dgvBayerFormatBayerRG,
    dgvBayerFormatBayerGB,
    dgvBayerFormatBayerBG
};

extern CoABayerFormatType   bayerFormatTypeFromPixelFormat(UInt32 pixelFormatValue);

extern UInt32               occupybitsFromPixelFormat(UInt32 pixelFormatValue);
extern UInt32               dataBitsPerSampleFromPixelFormat(UInt32 pixelFormatValue);
extern BOOL                 isPixelAlignedInByteFromPixelFormat(UInt32 pixelFormatValue);
extern BOOL                 isChannelAlignedInByteFromPixelFormat(UInt32 pixelFormatValue);
