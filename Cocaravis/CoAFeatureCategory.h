//
//  CoAFeatureCategory.h
//  Cocaravis
//
//  Created by decafish on 2019/6/28.
//  Copyright illusia decafish. All rights reserved.
//

#import <Foundation/Foundation.h>

/*
    CoAFeatureCategory class classifies camera features
    to groups of features according to gen<i>Cam category nodes
    If Root category of Gen<i>Cam description is flat,
    the property categorizedFeatures returns dictionary with
    feature name for key and CoACameraFeature object for value.
    If Root category is nested, categorizedFeatures returns nested dictionaries.
 */


NS_ASSUME_NONNULL_BEGIN

@class CoADevice;
@class CoACameraFeature;

@interface CoAFeatureCategory : NSObject
@property (readonly) NSDictionary   *categorizedFeatures;

- (instancetype)initWithDevice:(CoADevice *)device;

- (CoACameraFeature *)featureByName:(NSString *)featureName;

@end

NS_ASSUME_NONNULL_END
