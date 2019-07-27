//
//  CoABuffer.m
//  Cocaravis
//
//  Created by decafish on 2019/6/17.
//  Copyright illusia decafish. All rights reserved.
//

#include <string.h>
#include <arv.h>
#import "CoABuffer.h"
#import "CoAPixelFormat.h"

static NSInteger    CoABufferStatusFromArvStatus(int arvStatus);
static NSInteger    CoABufferPayloadTypeFromArvPalyloadType(int type);


@interface CoABuffer ()
@property (readwrite) CoABufferStatus       status;
@property (readwrite) CoABufferPayloadType  payloadType;
@property (readwrite) NSUInteger            timeStamp;
@property (readwrite) NSUInteger            frameId;
@property (readwrite) ArvBuffer             *buffer;
@property (readwrite) NSData                *content;

@end

#pragma mark    *********** CoABuffer   ***************

@implementation CoABuffer

+ (instancetype)bufferWithArvBuffer:(ArvBuffer *)buffer
{
    if (arv_buffer_get_payload_type(buffer) == ARV_BUFFER_PAYLOAD_TYPE_IMAGE)
        return [[CoAImageBuffer alloc] initWithArvBuffer:buffer];
    return [[CoABuffer alloc] initWithArvBuffer:buffer];
}

- (instancetype)initWithArvBuffer:(ArvBuffer *)buffer
{
    self = [super init];
    _buffer = buffer;
    _status = CoABufferStatusFromArvStatus(arv_buffer_get_status(buffer));
    _payloadType = CoABufferPayloadTypeFromArvPalyloadType(arv_buffer_get_payload_type(buffer));
    _timeStamp = arv_buffer_get_timestamp(buffer);
    _frameId = arv_buffer_get_frame_id(buffer);
    size_t      contentSize;
    const void  *tmp = arv_buffer_get_data(buffer, &contentSize);
    _content = [NSData dataWithBytesNoCopy:(void *)tmp length:contentSize freeWhenDone:NO];
    return self;
}

- (id)initWithCoABuffer:(CoABuffer *)buffer withFrameDataNoCopy:(NSData *)frameData
{
    self = [super init];
    _status = buffer.status;
    _payloadType = buffer.payloadType;
    _timeStamp = buffer.timeStamp;
    _frameId = buffer.frameId;
    _content = frameData;
    return self;
}


@end


#pragma mark    *********** CoAImageBuffer   ************

@interface CoAImageBuffer ()

//  converter for bayer to RGB format wanted to be implemented with
//  1. using GPU (via. Metal?)
//  2. fixing design for extra pxiels surrounding standrad area with 4:3
//- (void)convertBayer:(const void *)bayer toShrinkedRGBA:(UInt8 *)rgbPlane withWhiteBaranceR:(float)wr G:(float)wg B:(float)wb;
@end


@implementation CoAImageBuffer

- (instancetype)initWithArvBuffer:(ArvBuffer *)buffer
{
    self = [super initWithArvBuffer:buffer];
    _pixelFormat = (UInt32)arv_buffer_get_image_pixel_format(buffer);
    gint    width = arv_buffer_get_image_width(buffer);
    gint    height = arv_buffer_get_image_height(buffer);
    _imageSize = NSMakeSize(width * 1.0, height * 1.0);
    return self;
}

- (id)initWithImageBuffer:(CoAImageBuffer *)imageBuffer withFrameDataNoCopy:(NSData *)frameData
{
    self = [super initWithCoABuffer:(CoABuffer *)imageBuffer withFrameDataNoCopy:frameData];
    _pixelFormat = imageBuffer.pixelFormat;
    _imageSize = imageBuffer.imageSize;
    return self;
}


- (NSData *)imageData
{
    return self.content;//[NSData dataWithBytes:self.content.bytes length:self.content.length];
}


- (UInt8 *)rawImageBytes
{
    return (UInt8 *)super.content.bytes;
}

@end


//  these functions are very redundant, but necessary not to include arv.h

static NSInteger    CoABufferStatusFromArvStatus(int arvStatus)
{
    NSInteger   ret = CoABufferStatusUnknown;
    switch (arvStatus) {
        case ARV_BUFFER_STATUS_SUCCESS:
            ret = CoABufferStatusSuccsess;          break;
        case ARV_BUFFER_STATUS_CLEARED:
            ret = CoABufferStatusCleared;           break;
        case ARV_BUFFER_STATUS_TIMEOUT:
            ret = CoABufferStatusTimeOut;           break;
        case ARV_BUFFER_STATUS_MISSING_PACKETS:
            ret = CoABufferStatusMissingPackets;    break;
        case ARV_BUFFER_STATUS_WRONG_PACKET_ID:
            ret = CoABufferStatusWrongPacketId;     break;
        case ARV_BUFFER_STATUS_SIZE_MISMATCH:
            ret = CoABufferStatusSizeMissMatch;     break;
        case ARV_BUFFER_STATUS_FILLING:
            ret = CoABufferStatusFilling;           break;
        case ARV_BUFFER_STATUS_ABORTED:
            ret = CoABufferStatusAborted;           break;
    }
    return ret;
}
static NSInteger    CoABufferPayloadTypeFromArvPalyloadType(int type)
{
    NSInteger   ret = CoABufferPayloadTypeUnknown;
    switch(type) {
        case ARV_BUFFER_PAYLOAD_TYPE_IMAGE:
            ret = CoABufferPayloadTypeImage;                break;
        case ARV_BUFFER_PAYLOAD_TYPE_RAWDATA:
            ret = CoABufferPayloadTypeRawData;              break;
        case ARV_BUFFER_PAYLOAD_TYPE_FILE:
            ret = CoABufferPayloadTypeFile;                 break;
        case ARV_BUFFER_PAYLOAD_TYPE_CHUNK_DATA:
            ret = CoABufferPayloadTypeChunkData;            break;
        case ARV_BUFFER_PAYLOAD_TYPE_EXTENDED_CHUNK_DATA:
            ret = CoABufferPayloadTypeExtendedChunkData;    break;
        case ARV_BUFFER_PAYLOAD_TYPE_JPEG:
            ret = CoABufferPayloadTypeJPEG;                 break;
        case ARV_BUFFER_PAYLOAD_TYPE_JPEG2000:
            ret = CoABufferPayloadTypeJPEG2000;             break;
        case ARV_BUFFER_PAYLOAD_TYPE_H264:
            ret = CoABufferPayloadTypeH264;                 break;
        case ARV_BUFFER_PAYLOAD_TYPE_MULTIZONE_IMAGE:
            ret = CoABufferPayloadTypeMultiZoneImage;       break;
    }
    return ret;
}

