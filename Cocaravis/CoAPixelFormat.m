//
//  CoAPixelFormat.m
//  GigECamera
//
//  Created by decafish on 2015/02/27.
//  Copyright (c) 2015 decafish. All rights reserved.
//

#import "CoAPixelFormat.h"


//  FOOLISH, UNGLY AND DIRTY FORMAT
//  I hate it.

const UInt32 GVSP_PIX_MONO                          = 0x01000000;
const UInt32 GVSP_PIX_RGB                           = 0x02000000; // deprecated in version 1.1
const UInt32 GVSP_PIX_COLOR                         = 0x02000000;
const UInt32 GVSP_PIX_CUSTOM                        = 0x80000000;
const UInt32 GVSP_PIX_COLOR_MASK                    = 0xFF000000;

const UInt32 GVSP_PIX_OCCUPY8BIT                    = 0x00080000;
const UInt32 GVSP_PIX_OCCUPY12BIT                   = 0x000C0000;
const UInt32 GVSP_PIX_OCCUPY16BIT                   = 0x00100000;
const UInt32 GVSP_PIX_OCCUPY24BIT                   = 0x00180000;
const UInt32 GVSP_PIX_OCCUPY32BIT                   = 0x00200000;
const UInt32 GVSP_PIX_OCCUPY36BIT                   = 0x00240000;
const UInt32 GVSP_PIX_OCCUPY48BIT                   = 0x00300000;
const UInt32 GVSP_PIX_EFFECTIVE_PIXEL_SIZE_MASK     = 0x00FF0000;
const UInt32 GVSP_PIX_EFFECTIVE_PIXEL_SIZE_SHIFT    = 16;

const UInt32 GVSP_PIX_ID_MASK                       = 0x0000FFFF;

const UInt32 GVSP_PIX_MONO8                         = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x0001);
const UInt32 GVSP_PIX_MONO8_SIGNED                  = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x0002);
const UInt32 GVSP_PIX_MONO10                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0003);
const UInt32 GVSP_PIX_MONO10_PACKED                 = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0004);
const UInt32 GVSP_PIX_MONO12                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0005);
const UInt32 GVSP_PIX_MONO12_PACKED                 = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0006);
const UInt32 GVSP_PIX_MONO14                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0025);
const UInt32 GVSP_PIX_MONO16                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0007);

const UInt32 GVSP_PIX_BAYGR8                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x0008);
const UInt32 GVSP_PIX_BAYRG8                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x0009);
const UInt32 GVSP_PIX_BAYGB8                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x000A);
const UInt32 GVSP_PIX_BAYBG8                        = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY8BIT   | 0x000B);
const UInt32 GVSP_PIX_BAYGR10                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x000C);
const UInt32 GVSP_PIX_BAYRG10                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x000D);
const UInt32 GVSP_PIX_BAYGB10                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x000E);
const UInt32 GVSP_PIX_BAYBG10                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x000F);
const UInt32 GVSP_PIX_BAYGR12                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0010);
const UInt32 GVSP_PIX_BAYRG12                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0011);
const UInt32 GVSP_PIX_BAYGB12                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0012);
const UInt32 GVSP_PIX_BAYBG12                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0013);

const UInt32 GVSP_PIX_BAYGR10_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0026);
const UInt32 GVSP_PIX_BAYRG10_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0027);
const UInt32 GVSP_PIX_BAYGB10_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0028);
const UInt32 GVSP_PIX_BAYBG10_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x0029);
const UInt32 GVSP_PIX_BAYGR12_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x002A);
const UInt32 GVSP_PIX_BAYRG12_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x002B);
const UInt32 GVSP_PIX_BAYGB12_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x002C);
const UInt32 GVSP_PIX_BAYBG12_PACKED                = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY12BIT  | 0x002D);
const UInt32 GVSP_PIX_BAYGR16                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x002E);
const UInt32 GVSP_PIX_BAYRG16                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x002F);
const UInt32 GVSP_PIX_BAYGB16                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0030);
const UInt32 GVSP_PIX_BAYBG16                       = (GVSP_PIX_MONO | GVSP_PIX_OCCUPY16BIT  | 0x0031);

const UInt32 GVSP_PIX_RGB8_PACKED                   = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY24BIT | 0x0014);
const UInt32 GVSP_PIX_BGR8_PACKED                   = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY24BIT | 0x0015);
const UInt32 GVSP_PIX_RGBA8_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY32BIT | 0x0016);
const UInt32 GVSP_PIX_BGRA8_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY32BIT | 0x0017);
const UInt32 GVSP_PIX_RGB10_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0018);
const UInt32 GVSP_PIX_BGR10_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0019);
const UInt32 GVSP_PIX_RGB12_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x001A);
const UInt32 GVSP_PIX_BGR12_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x001B);
const UInt32 GVSP_PIX_RGB16_PACKED                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0033);
const UInt32 GVSP_PIX_RGB10V1_PACKED                = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY32BIT | 0x001C);
const UInt32 GVSP_PIX_RGB10V2_PACKED                = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY32BIT | 0x001D);
const UInt32 GVSP_PIX_RGB12V1_PACKED                = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY36BIT | 0X0034);

const UInt32 GVSP_PIX_YUV411_PACKED                 = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY12BIT | 0x001E);
const UInt32 GVSP_PIX_YUV422_PACKED                 = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY16BIT | 0x001F);
const UInt32 GVSP_PIX_YUV422_YUYV_PACKED            = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY16BIT | 0x0032);
const UInt32 GVSP_PIX_YUV444_PACKED                 = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY24BIT | 0x0020);

const UInt32 GVSP_PIX_RGB8_PLANAR                   = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY24BIT | 0x0021);
const UInt32 GVSP_PIX_RGB10_PLANAR                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0022);
const UInt32 GVSP_PIX_RGB12_PLANAR                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0023);
const UInt32 GVSP_PIX_RGB16_PLANAR                  = (GVSP_PIX_COLOR | GVSP_PIX_OCCUPY48BIT | 0x0024);

CoAColorFormatType  colorFormatTypeFromPixelFormat(UInt32 pixelFormatValue)
{
    CoAColorFormatType  ftype = dgvColorFormatRGB;
    BOOL    isMono = (pixelFormatValue & GVSP_PIX_MONO) != 0;
    UInt32  pixId = (pixelFormatValue & GVSP_PIX_ID_MASK);
    if (isMono) {
        if (pixId == 0x0002)
            ftype = dgvColorFormatSignedMonochrome;
        else if ((pixId <= 0x0007) || (pixId == 0x0025))
            ftype = dgvColorFormatMonochrome;
        else if (pixId <= 0x0031)
            ftype = dgvColorFormatBayer;
        else
            ftype = dgvColorFormatOther;
    }
    else {
        if ((pixId == 0x001E) || (pixId == 0x001F) || (pixId == 0x0032) || (pixId == 0x0020))
            ftype = dgvColorFormatYUV;
        else if ((pixId == 0x0021) || (pixId == 0x0022) || (pixId == 0x0023) || (pixId == 0x0024))
            ftype = dgvColorFormatPlanerRGB;
        else if ((pixId == 0x0016) || (pixId == 0x0017))
            ftype = dgvColorFormatRGBA;
        else if ((pixId >= 0x0014) && (pixId <= 0x0034))
            ftype = dgvColorFormatRGB;
    }
    return ftype;
}

CoABayerFormatType   bayerFormatTypeFromPixelFormat(UInt32 pixelFormatValue)
{
    CoABayerFormatType  bayer = dgvBayerFormatNotBayer;
    if (colorFormatTypeFromPixelFormat(pixelFormatValue) != dgvColorFormatBayer)
        bayer = dgvBayerFormatNotBayer;
    else if ((pixelFormatValue == GVSP_PIX_BAYGR8) ||
             (pixelFormatValue == GVSP_PIX_BAYGR10) ||
             (pixelFormatValue == GVSP_PIX_BAYGR12) ||
             (pixelFormatValue == GVSP_PIX_BAYGR10_PACKED) ||
             (pixelFormatValue == GVSP_PIX_BAYGR12_PACKED))
        bayer = dgvBayerFormatBayerGR;
    else if ((pixelFormatValue == GVSP_PIX_BAYRG8) ||
             (pixelFormatValue == GVSP_PIX_BAYRG10) ||
             (pixelFormatValue == GVSP_PIX_BAYRG12) ||
             (pixelFormatValue == GVSP_PIX_BAYRG10_PACKED) ||
             (pixelFormatValue == GVSP_PIX_BAYRG12_PACKED))
        bayer = dgvBayerFormatBayerRG;
    else if ((pixelFormatValue == GVSP_PIX_BAYGB8) ||
             (pixelFormatValue == GVSP_PIX_BAYGB10) ||
             (pixelFormatValue == GVSP_PIX_BAYGB12) ||
             (pixelFormatValue == GVSP_PIX_BAYGB10_PACKED) ||
             (pixelFormatValue == GVSP_PIX_BAYGB12_PACKED))
        bayer = dgvBayerFormatBayerGB;
    else if ((pixelFormatValue == GVSP_PIX_BAYBG8) ||
             (pixelFormatValue == GVSP_PIX_BAYBG10) ||
             (pixelFormatValue == GVSP_PIX_BAYBG12) ||
             (pixelFormatValue == GVSP_PIX_BAYBG10_PACKED) ||
             (pixelFormatValue == GVSP_PIX_BAYBG12_PACKED))
        bayer = dgvBayerFormatBayerBG;
    return bayer;
}

UInt32  occupybitsFromPixelFormat(UInt32 pixelFormatValue)
{
    return ((pixelFormatValue & GVSP_PIX_EFFECTIVE_PIXEL_SIZE_MASK) >> GVSP_PIX_EFFECTIVE_PIXEL_SIZE_SHIFT);
}

UInt32  dataBitsPerSampleFromPixelFormat(UInt32 pixelFormatValue)
{
    if (((pixelFormatValue & GVSP_PIX_MONO) != 0) && (bayerFormatTypeFromPixelFormat(pixelFormatValue) == dgvBayerFormatNotBayer)) {
        if (pixelFormatValue == GVSP_PIX_MONO10_PACKED)
            return 10;
        else if (pixelFormatValue == GVSP_PIX_MONO12_PACKED)
            return 12;
        return occupybitsFromPixelFormat(pixelFormatValue);
    }
    return 8;   //  others, I don't know
}

BOOL    isPixelAlignedInByteFromPixelFormat(UInt32 pixelFormatValue)
{
    return (occupybitsFromPixelFormat(pixelFormatValue) & 0x00000007) == 0;
}

BOOL    isChannelAlignedInByteFromPixelFormat(UInt32 pixelFormatValue)
{
    return YES; //  I think I can not implement forever.
}

