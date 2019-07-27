//
//  CoACameraFinder.h
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    CoACameraFinder class
    enumerate device signatures of connected cameras via. GigE and USB3
 */
NS_ASSUME_NONNULL_BEGIN

@class CoADevice;

//  for meanings of each property, refer aravis document
//  interfaceId property is disabled because
//  arv_get_interface_id() returns meaningless string for more than one camera on same interface @0.6.3

@interface CoADeviceSignature : NSObject
@property (readonly) NSString       *deviceId;
@property (readonly) NSString       *physicalId;
@property (readonly) NSString       *model;
@property (readonly) NSString       *serialNumber;
@property (readonly) NSString       *vendor;
@property (readonly) NSString       *address;
@property (readonly) NSString       *protocol;
//@property (readonly) NSString       *interfaceId;
@end



@interface CoACameraFinder : NSObject
@property (readonly) NSArray<NSString *>                *interfaceIdentifiers;
@property (readonly) NSArray<CoADeviceSignature *>      *connectedDevices;


+ (CoACameraFinder *)sharedCameraFinder;

- (void)shutdown;

@end

NS_ASSUME_NONNULL_END
