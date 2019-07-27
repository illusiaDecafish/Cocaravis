//
//  CoACameraFinder.m
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>

#import "CoACameraFinder.h"

static CoACameraFinder  *sharedFinder = nil;
static NSArray          *interfaces = nil;

#pragma mark    *********** CoADeviceSignature  **********

@interface CoADeviceSignature ()
@property (readwrite) NSString      *deviceId;
@property (readwrite) NSString      *physicalId;
@property (readwrite) NSString      *model;
@property (readwrite) NSString      *serialNumber;
@property (readwrite) NSString      *vendor;
@property (readwrite) NSString      *address;
@property (readwrite) NSString      *protocol;
//@property (readwrite) NSString      *interfaceId;
@end
@implementation CoADeviceSignature

- (NSString *)description
{
    NSMutableString *str = [NSMutableString string];
    [str appendFormat:@"Camera %@", self.deviceId];
    [str appendFormat:@"\tID %@", self.physicalId];
    [str appendFormat:@"\tModel %@", self.model];
    [str appendFormat:@"\tSerial number %@", self.serialNumber];
    [str appendFormat:@"\tVender %@", self.vendor];
    [str appendFormat:@"\tAddress %@", self.address];
    [str appendFormat:@"\tProtocol %@", self.protocol];
    //[str appendFormat:@"\tInterface ID %@", self.interfaceId];
    return [NSString stringWithString:str];
}
@end


#pragma mark    **********  CoACameraFinder ************

@interface CoACameraFinder ()
@property NSArray   *cameraNameList;

- (NSString *)stringFromCStringNullChecking:(const char *)cstr;

@end


@implementation CoACameraFinder

//  CoACameraFinder is a simple simgleton, can not be subclassed.
+ (CoACameraFinder *)sharedCameraFinder
{
    if (sharedFinder == nil)
        sharedFinder = [[CoACameraFinder alloc] init];
    return sharedFinder;
}

- (instancetype)init
{
    self = [super init];

    arv_update_device_list();
    _cameraNameList = nil;
    
    return self;
}

- (NSArray<NSString *> *)interfaceIdentifiers
{
    if (interfaces == nil) {
        unsigned        n = arv_get_n_interfaces();
        if (n == 0)
            return nil;
        NSMutableArray  *iid = [NSMutableArray arrayWithCapacity:n];
        for (unsigned i = 0 ; i < n ; i ++) {
            const char  *iname = arv_get_interface_id(i);
            NSString    *str = [NSString stringWithCString:iname encoding:NSASCIIStringEncoding];
            [iid addObject:str];
        }
        interfaces = [NSArray arrayWithArray:iid];
    }
    return interfaces;
}

- (NSString *)stringFromCStringNullChecking:(const char *)cstr
{
    static const char   *placeHolder = "";
    const char  *tmp;
    if (cstr != NULL)
        tmp = cstr;
    else
        tmp = placeHolder;
    return [NSString stringWithCString:tmp encoding:NSASCIIStringEncoding];
}

- (NSArray<CoADeviceSignature *> *)connectedDevices
{
    if (_cameraNameList == nil) {
        NSMutableArray  *temp = [NSMutableArray new];
        unsigned int    num = arv_get_n_devices();
        for (unsigned i = 0 ; i < num ; i ++) {
            CoADeviceSignature  *cprop = [CoADeviceSignature new];
            cprop.deviceId = [self stringFromCStringNullChecking:arv_get_device_id(i)];
            cprop.physicalId = [self stringFromCStringNullChecking:arv_get_device_physical_id(i)];
            cprop.model = [self stringFromCStringNullChecking:arv_get_device_model(i)];
            cprop.serialNumber = [self stringFromCStringNullChecking:arv_get_device_serial_nbr(i)];
            cprop.vendor = [self stringFromCStringNullChecking:arv_get_device_vendor(i)];
            cprop.address = [self stringFromCStringNullChecking:arv_get_device_address(i)];
            cprop.protocol = [self stringFromCStringNullChecking:arv_get_device_protocol(i)];
            //cprop.interfaceId = [self stringFromCStringNullChecking:arv_get_interface_id(i)];
            [temp addObject:cprop];
        }
        _cameraNameList = [NSArray arrayWithArray:temp];
    }
    return _cameraNameList;
}

- (void)shutdown
{
    arv_shutdown();
}

@end


