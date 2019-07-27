//
//  CoACamera.h
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoACameraFinder.h"

/*
    CoACamera class, wrapper of ArvCamera
    to init CoACamera object one device signature shoulde be wspecified
    even if only one camera is connected.
 */


NS_ASSUME_NONNULL_BEGIN


//  camera property settings
typedef NS_ENUM(NSInteger, autoValueSetting) {
    autoOff,
    autoOnce,
    autoContinuous,
    autoNotImplemented
};

@class CoACamera;


//  CoAAcquisitionProperty classes represent directly each funtions of ArvCamera control.
//  reffer ArvCamera.h
@interface CoAAcquisitionProperty : NSObject
@property (readonly, weak) CoACamera    *camera;
@property (readonly) NSString           *name;
@property (readonly) NSString           *unit;
@property (readwrite) autoValueSetting  valueAuto;

+ (NSString *)propertyNameString;

@end

@interface CoAEnumarateAcquisitionProperty : CoAAcquisitionProperty
@property (readonly) NSArray            *availableValues;
@property (readwrite) NSString          *currentValue;
@end
@interface CoATriggerSourceAcquisitionProperty : CoAEnumarateAcquisitionProperty
@end
@interface CoATriggerModeAcquisitionProperty : CoAEnumarateAcquisitionProperty
@end

@interface CoAFloatAcquisitionProperty : CoAAcquisitionProperty
@property (readonly) double             min;
@property (readonly) double             max;
@property (readwrite) double            currentValue;
@end

@interface CoAIntegerAcquisitionProperty : CoAAcquisitionProperty
@property (readonly) NSInteger          min;
@property (readonly) NSInteger          max;
@property (readwrite) NSInteger         currentValue;
@end

@interface CoA2DIntegerAcquisitionProperty : CoAIntegerAcquisitionProperty
@property (readonly) NSInteger          ymin;
@property (readonly) NSInteger          ymax;
@property (readwrite) NSInteger         ycurrentValue;
@end


#pragma mark    frame rate property
@interface CoAFrameRateAcquisitionProperty : CoAFloatAcquisitionProperty
@end

#pragma mark    exposure time property
@interface CoAExposureTimeAcquisitionProperty : CoAFloatAcquisitionProperty
@end

#pragma mark    gain property
@interface CoAGainAcquisitionProperty : CoAFloatAcquisitionProperty
@end

#pragma mark    binning property
@interface CoABinnigAcquisitionProperty : CoA2DIntegerAcquisitionProperty
@end




@class CoAStream;
@class CoADevice;
@class CoACameraFeature;

#pragma mark *************************** CoACamera *******************************

//  for my convenience, ROI, regionOfInterest is set to standard size in default,
//  not full sensor size if it is not standard
//  because some imagers have slightly different aspect ratio from 4:3 for full area
//  Check default size of regionOfInterest for your camera.
//  by decafish @2019/6/15

@interface CoACamera : NSObject
@property (readonly) CoADeviceSignature                 *signature;
@property (readonly) NSSize                             sensorPixelSize;
@property (readwrite) NSRect                            regionOfInterest;
@property (readonly) NSArray <NSString *>               *availablePixelFormats;
@property (readwrite) NSString                          *pixelFormat;
@property (readonly) NSArray <NSString *>               *availableAcquisitioModes;
@property (readwrite) NSString                          *acquisitionMode;

@property (readonly) NSArray <NSString *>               *availablePropertyNames;
@property (readonly) NSArray <CoAAcquisitionProperty *> *acquisitionProperties;

+ (NSArray <NSString *> *)aquisitionPropertyNames;


- (instancetype)initWithDeviceSignature:(CoADeviceSignature * __nonnull)signature;

- (CoADevice *)cameraDevice;

- (CoAAcquisitionProperty *)propertyByName:(NSString *)name;
- (Class)classOfPropertyByName:(NSString *)name;


//  to create CoAStream object, the method below should be used.
//  stream object should be created after setting regionOfIntererst of the camera object
//  because buffer size may differ and aravis pools buffers beforehand.
//  if you want change regionOfInterest,
//  1.  stop acquisition
//  2.  alter regionOfInterest
//  3.  create new stream
//  4.  start acquisition
- (CoAStream *)createCoAStreamWithPooledBufferCount:(NSUInteger)count;

- (void)startAquisition;
- (void)stopAquisition;
- (void)abortAquisition;


//  reffer to CoAPixelFormat.h for the integer argument.
//  if nil, the camera can not support the format
- (NSString *)pixelFormatStringFromEnumValue:(NSInteger)value;




//  for CoAStream, users for CoACamera object need not to care with them.
typedef struct _ArvStream       ArvStream;
typedef struct _ArvDevice       ArvDevice;

- (NSUInteger)currentPayloadSize;
- (ArvStream *)createArvStream;

//  for CoAFeatureCategory
typedef struct _ArvCamera       ArvCamera;
- (ArvCamera *)arvCameraObject;

@end

NS_ASSUME_NONNULL_END
