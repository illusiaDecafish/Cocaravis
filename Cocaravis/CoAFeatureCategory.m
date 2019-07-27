//
//  CoAFeatureCategory.m
//  Cocaravis
//
//  Created by decafish on 2019/6/28.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>

#import "CoAFeatureCategory.h"
#import "CoADevice.h"
#import "CoACameraFeature.h"

static const char   *rootCategoryName       = "Root";


@interface CoAFeatureCategory ()
@property (readonly) CoADevice      *device;
@property (readonly) NSDictionary   *featuresCache;

- (NSDictionary *)singleLevelCategory:(ArvGcCategory *)categoryNode fromGenICam:(ArvGc *)genicam;
- (CoACameraFeature *)findFeatureByName:(NSString *)featureName from:(NSDictionary *)category;

@end

@implementation CoAFeatureCategory

- (instancetype)initWithDevice:(CoADevice *)device
{
    self = [super init];
    _device = device;
    _featuresCache = nil;
    return self;
}

- (NSDictionary *)categorizedFeatures
{
    if (_featuresCache == nil) {
        ArvGc *gc = arv_device_get_genicam([self.device arvDeviceObject]);
        if (gc == NULL)
            return nil;
        
        ArvGcNode   *node = arv_gc_get_node(gc, rootCategoryName);
        
        if (g_type_is_a(G_OBJECT_TYPE(node), ARV_TYPE_GC_CATEGORY)) {
            //NSString    *catName = [NSString stringWithCString:rootCategoryName encoding:NSASCIIStringEncoding];
            _featuresCache = [self singleLevelCategory:(ArvGcCategory *)node fromGenICam:gc];
        }
    }
    return _featuresCache;
}

- (NSDictionary *)singleLevelCategory:(ArvGcCategory *)categoryNode fromGenICam:(ArvGc *)genicam
{
    GSList  *clist = (GSList *)arv_gc_category_get_features(categoryNode);
    guint   len = g_slist_length(clist);
    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithCapacity:len];
    for (guint i = 0 ; i < len ; i ++) {
        const char  *nm = g_slist_nth_data(clist, i);
        ArvGcNode   *node = arv_gc_get_node(genicam, nm);
        NSString *nodeName = [NSString stringWithUTF8String:nm];
        if (g_type_is_a(G_OBJECT_TYPE(node), ARV_TYPE_GC_CATEGORY)) {
            NSDictionary *childCat = [self singleLevelCategory:(ArvGcCategory *)node fromGenICam:genicam];
            [tmp setObject:childCat forKey:nodeName];
        }
        else {
            CoACameraFeature    *feature = [CoACameraFeature cameraFeatureWithDevice:self.device featureName:nodeName];
            if (feature != nil) {
                [tmp setObject:feature forKey:nodeName];
            }
        }
    }
    return [NSDictionary dictionaryWithDictionary:tmp];
}

- (CoACameraFeature *)featureByName:(NSString *)featureName
{
    return [self findFeatureByName:featureName from:self.categorizedFeatures];
}

- (CoACameraFeature *)findFeatureByName:(NSString *)featureName from:(NSDictionary *)category
{
    id  ret = [category objectForKey:featureName];
    if (ret != nil) {
        if ([ret isKindOfClass:[CoACameraFeature class]])
            return (CoACameraFeature *)ret;
        else
            return nil;
    }
    else {
        NSArray *allvals = [category allValues];
        __block id  ret2 = nil;
        [allvals enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[NSDictionary class]]) {
                CoACameraFeature  *retin = [self findFeatureByName:featureName from:obj];
                if (retin != nil) {
                    ret2 = retin;
                    *stop = YES;
                }
            }
        }];
        return (CoACameraFeature *)ret2;
    }
    return nil;
}


@end
