//
//  CoADevice.h
//  Cocaravis
//
//  Created by decafish on 2019/7/10.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoACameraFinder.h"

/*
    CoADevice class, a wrapper of ArvDevice
 */

NS_ASSUME_NONNULL_BEGIN

@class CoAStream;
@class CoACamera;
@class CoACameraFeature;

//  notification below is issued when ArvDevice araises control-lost signal
extern NSString *CoADeviceControlLostNotification;

@interface CoADevice : NSObject
@property (readonly) NSString                       *deviceId;
@property (readonly) NSDictionary                   *categorizedFeatures;


- (instancetype)initWithCamera:(CoACamera *)camera;

- (CoACameraFeature *)featureByName:(NSString *)featureName;


//  for CoAStream
typedef struct _ArvDevice ArvDevice;
- (ArvDevice *)arvDeviceObject;

@end

NS_ASSUME_NONNULL_END
