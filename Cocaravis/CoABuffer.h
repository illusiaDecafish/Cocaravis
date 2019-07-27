//
//  CoABuffer.h
//  Cocaravis
//
//  Created by decafish on 2019/6/17.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    CoABuffer class, a wrapper of ArvBuffer
    Only image payload type is implemented
    to a subclass CoAImageBuffer in current version.
 */

NS_ASSUME_NONNULL_BEGIN


//  according to aravis ArvBufferStatus.
typedef NS_ENUM(NSInteger, CoABufferStatus) {
    CoABufferStatusUnknown,
    CoABufferStatusSuccsess,
    CoABufferStatusCleared,
    CoABufferStatusTimeOut,
    CoABufferStatusMissingPackets,
    CoABufferStatusWrongPacketId,
    CoABufferStatusSizeMissMatch,
    CoABufferStatusFilling,
    CoABufferStatusAborted
};


//  according to aravis payload types.
//  not all types are supported in curent version.
typedef NS_ENUM(NSInteger, CoABufferPayloadType) {
    CoABufferPayloadTypeUnknown,
    CoABufferPayloadTypeImage,
    CoABufferPayloadTypeRawData,
    CoABufferPayloadTypeFile,
    CoABufferPayloadTypeChunkData,
    CoABufferPayloadTypeExtendedChunkData,
    CoABufferPayloadTypeJPEG,
    CoABufferPayloadTypeJPEG2000,
    CoABufferPayloadTypeH264,
    CoABufferPayloadTypeMultiZoneImage
};


@interface CoABuffer : NSObject
@property (readonly) CoABufferStatus        status;
@property (readonly) CoABufferPayloadType   payloadType;
@property (readonly) NSUInteger             timeStamp;
@property (readonly) NSUInteger             frameId;

typedef struct _ArvBuffer ArvBuffer;

+ (instancetype)bufferWithArvBuffer:(ArvBuffer *)buffer;

- (instancetype)initWithArvBuffer:(ArvBuffer *)buffer;
- (id)initWithCoABuffer:(CoABuffer *)buffer withFrameDataNoCopy:(NSData *)frameData;

@end


#pragma mark    CoAImageBuffer for image payload type
@interface CoAImageBuffer : CoABuffer
@property (readonly) UInt32                 pixelFormat;
@property (readonly) NSSize                 imageSize;
@property (readonly) NSData                 *imageData; //  copying buffer content

@property (readonly) UInt8                  *rawImageBytes;
//
- (id)initWithImageBuffer:(CoAImageBuffer *)imageBuffer withFrameDataNoCopy:(NSData *)frameData;

@end


NS_ASSUME_NONNULL_END
