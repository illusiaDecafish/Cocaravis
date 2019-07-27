//
//  CoACameraFeature.h
//  Cocaravis
//
//  Created by decafish on 2019/6/28.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    CoACameraFeature class, to control camera features
    via. ArvFeatureNode, Gen<i>Cam node
 */


NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSInteger, imposedAccessMode) {
    IAMReadOnly,
    IAMWriteOnly,
    IAMReadWrite
};

typedef struct _ArvGcFeatureNode ArvGcFeatureNode;

@class CoADevice;

@interface CoACameraFeature : NSObject
@property (readonly, weak) CoADevice    *device;
@property (readonly) NSString           *name;
@property (readonly) NSString           *displayName;
@property (readonly) NSString           *toolTip;
@property (readonly) NSString           *featureDescription;
@property (readonly) BOOL               isImpelemted;
@property (readonly) BOOL               isAvailable;
@property (readonly) BOOL               isLocked;
@property (readonly) imposedAccessMode  accessMode;

+ (NSString *)genicamNodeName;

+ (instancetype)cameraFeatureWithDevice:(CoADevice *)device featureName:(NSString *)featureName;

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName;

@end


#pragma mark *************   CoABooleanFeature
//  ARV_TYPE_GC_BOOLEAN node type
@interface CoABooleanFeature : CoACameraFeature
@property (readonly) BOOL   currentValue;

- (BOOL)setBoolValue:(BOOL)value;

@end


#pragma mark *************   CoAEnumerationFeature
//  ARV_TYPE_GC_ENUMERATION node type
@interface CoAEnumerationFeature : CoACameraFeature
@property (readonly) NSArray <NSString *>   *availableValues;
@property (readonly) NSString               *currentValue;

- (BOOL)setEnumEntryValue:(NSString *)value;

@end


#pragma mark *************   CoAStringFeature
//  ARV_TYPE_GC_STRING node type
@interface CoAStringFeature : CoACameraFeature
@property (readonly) NSString   *currentValue;

- (BOOL)setStringValue:(NSString *)value;

@end

#pragma mark *************   CoAFloatFeature
//  ARV_TYPE_GC_FLOAT_NODE node type
@interface CoAFloatFeature : CoACameraFeature
@property (readonly) NSString   *unit;
@property (readonly) CGFloat    min;
@property (readonly) CGFloat    max;
@property (readonly) CGFloat    currentValue;

- (BOOL)setFloatValue:(CGFloat)value;

@end

#pragma mark *************   CoAIntegerFeature
//  ARV_TYPE_GC_INTEGER_NODE node type
@interface CoAIntegerFeature : CoACameraFeature
@property (readonly) NSString   *unit;
@property (readonly) NSInteger  min;
@property (readonly) NSInteger  max;
@property (readonly) NSInteger  currentValue;

- (BOOL)setIntegerValue:(NSInteger)value;

@end


#pragma mark *************   CoACommandFeature
//  ARV_TYPE_GC_COMMAND node type
@interface CoACommandFeature : CoACameraFeature

- (BOOL)execute;

@end

typedef NS_ENUM(NSInteger, registerNodeType) {
    registerNodeTypeRegister,
    registerNodeTypeInteger,
    registerNodeTypeMaskedInteger,
    registerNodeTypeFloat,
    registerNodeTypeString,
    registerNodeTypeStructRegister
};

#pragma mark *************   CoARegisterFeature
//  ARV_TYPE_GC_REGISTER_NODE node type
@interface CoARegisterFeature : CoACameraFeature
@property (readonly) registerNodeType   type;
@end

NS_ASSUME_NONNULL_END
