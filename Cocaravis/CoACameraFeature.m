//
//  CoACameraFeature.m
//  Cocaravis
//
//  Created by decafish on 2019/6/28.
//  Copyright illusia decafish. All rights reserved.
//

#include <string.h>
#include <arv.h>
#import "CoACameraFeature.h"
#import "CoADevice.h"

static NSString         *noUnitString   = @"";

@interface CoACameraFeature ()
@property (readonly) ArvGcFeatureNode   *featureNode;
@property (readonly) const char         *fName;

- (NSString *)stringFromChars:(const char *)chars;
- (NSString *)unitString;

@end

@implementation CoACameraFeature

+ (NSString *)genicamNodeName
{
    return @"generic node";
}

+ (instancetype)cameraFeatureWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    const char  *fname = [featureName UTF8String];
    ArvGcNode   *fnode = arv_device_get_feature([device arvDeviceObject], fname);
    GType   type = G_OBJECT_TYPE(fnode);
    if (! g_type_is_a(type, ARV_TYPE_GC_FEATURE_NODE))
//  MACRO 'ARV_IS_GC_FEATURE_NODE' causes warning 'ambiguous macro expansion'
        return nil;

    id      obj = nil;
    if (type == ARV_TYPE_GC_BOOLEAN)
        obj = [[CoABooleanFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_FLOAT_NODE)
        obj = [[CoAFloatFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_ENUMERATION)
        obj = [[CoAEnumerationFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_STRING)
        obj = [[CoAStringFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_FLOAT_NODE)
        obj = [[CoAFloatFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_INTEGER_NODE)
        obj = [[CoAIntegerFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_COMMAND)
        obj = [[CoACommandFeature alloc] initWithDevice:device featureName:featureName];
    else if (type == ARV_TYPE_GC_REGISTER_NODE)
        obj = [[CoARegisterFeature alloc] initWithDevice:device featureName:featureName];
    else
        //  should be added other types.

    if (obj == nil)
        NSLog(@"object is nil %@ type %s", featureName, g_type_name(type));
    return obj;
}

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    const char  *fname = [featureName UTF8String];
    ArvGcNode   *fnode = arv_device_get_feature([device arvDeviceObject], fname);
    if (! g_type_is_a(G_TYPE_FROM_INSTANCE(fnode), ARV_TYPE_GC_FEATURE_NODE))
        return nil;
    
    self = [super init];
    _featureNode = (ArvGcFeatureNode *)fnode;
    _device = device;
    _fName = fname;
    
    _name = [self stringFromChars:arv_gc_feature_node_get_name(_featureNode)];
    GError  *error = NULL;
    const char  *dname = arv_gc_feature_node_get_display_name(_featureNode, &error);
    if (error == NULL)
        _displayName = [self stringFromChars:dname];
    else
        _displayName = nil;
    error = NULL;
    const char  *tt = arv_gc_feature_node_get_tooltip(_featureNode, &error);
    if (error == NULL)
        _toolTip = [self stringFromChars:tt];
    else
        _toolTip = nil;
    error = NULL;
    const char  *fd = arv_gc_feature_node_get_description(_featureNode, &error);
    if (error == NULL)
        _featureDescription = [self stringFromChars:fd];
    else
        _featureDescription = nil;
    return self;
}

- (NSString *)stringFromChars:(const char *)chars
{
    NSString    *ret = nil;
    if ((chars != NULL) && (*chars != '\0'))
        ret = [NSString stringWithUTF8String:chars];
    return ret;
}

- (BOOL)isImpelemted
{
    GError      *error = NULL;
    gboolean    yn = arv_gc_feature_node_is_implemented(_featureNode, &error);
    if (error == NULL)
        return yn;
    return NO;
}

- (BOOL)isAvailable
{
    GError      *error = NULL;
    gboolean    yn = arv_gc_feature_node_is_available(_featureNode, &error);
    if (error == NULL)
        return yn;
    return NO;
}

- (BOOL)isLocked
{
    GError      *error = NULL;
    gboolean    yn = arv_gc_feature_node_is_locked(_featureNode, &error);
    if (error == NULL)
        return yn;
    return NO;
}

- (NSString *)unitString
{
    ArvDomNodeList *nodeList = arv_dom_node_get_child_nodes((ArvDomNode *)self.featureNode);
    if (nodeList == NULL)
        return noUnitString;
    unsigned num = arv_dom_node_list_get_length(nodeList);
    for (unsigned i = 0 ; i < num ; i ++) {
        ArvGcPropertyNode *uni = (ArvGcPropertyNode *)arv_dom_node_list_get_item(nodeList, i);
        if (arv_gc_property_node_get_node_type(uni) == ARV_GC_PROPERTY_NODE_TYPE_UNIT) {
            GError  *error = NULL;
            const char  *unitchars = arv_gc_property_node_get_string(uni, &error);
            if ((unitchars == NULL) || (error != NULL))
                return noUnitString;
            return [NSString stringWithUTF8String:unitchars];
        }
    }
    return noUnitString;
}

- (NSString *)description
{
    NSString    *gtype = [NSString stringWithUTF8String:g_type_name(G_OBJECT_TYPE(self.featureNode))];
    return [NSString stringWithFormat:@"Feature name:%@(%@) type:%@ Description:%@", self.name, self.displayName, gtype, self.featureDescription];
}

@end


#pragma mark    *************   implementation of CoABooleanFeature ***********

@implementation CoABooleanFeature

+ (NSString *)genicamNodeName
{
    return @"Boolean";
}

- (BOOL)currentValue
{
    return arv_device_get_boolean_feature_value([super.device arvDeviceObject], super.fName);
}

- (BOOL)setBoolValue:(BOOL)value
{
    arv_device_set_boolean_feature_value([super.device arvDeviceObject], super.fName, value);
    return (self.currentValue == value);
}

@end

#pragma mark    *************   implementation of CoAEnumerationFeature ***********

@implementation CoAEnumerationFeature

+ (NSString *)genicamNodeName
{
    return @"Enumeration";
}

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    self = [super initWithDevice:device featureName:featureName];
    if (self == nil)
        return nil;

    guint   num;
    GError  *error = NULL;
    const char **entries = arv_gc_enumeration_get_available_string_values((ArvGcEnumeration *)(super.featureNode), &num, &error);
    if (error != NULL) {
        self = nil;
        return nil;
    }
    
    NSMutableArray  *tmp = [NSMutableArray arrayWithCapacity:num];
    for (guint i = 0 ; i < num ; i ++)
        [tmp addObject:[NSString stringWithUTF8String:entries[i]]];
    _availableValues = [NSArray arrayWithArray:tmp];
    
    return self;
}

- (NSString *)currentValue
{
    GError  *error = NULL;
    const char  *strval = arv_gc_enumeration_get_string_value((ArvGcEnumeration *)(super.featureNode), &error);
    if (error != NULL)
        return nil;
    
    NSString    *val = [NSString stringWithUTF8String:strval];
    __block NSString    *ret = nil;
    [self.availableValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([val isEqualToString:obj]) {
            *stop = YES;
            ret = obj;
        }
    }];
    return ret;
}

- (BOOL)setEnumEntryValue:(NSString *)value
{
    __block NSString    *ret = nil;
    [self.availableValues enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([value isEqualToString:obj]) {
            *stop = YES;
            ret = obj;
        }
    }];
    if (ret == nil)
        return NO;
    GError  *error = NULL;
    arv_gc_enumeration_set_string_value((ArvGcEnumeration *)(super.featureNode), [ret UTF8String], &error);
    if (error != NULL)
        return NO;
    return [ret isEqualToString:self.currentValue];
}

@end



#pragma mark    *************   implementation of CoAStringFeature ***********

@implementation CoAStringFeature

+ (NSString *)genicamNodeName
{
    return @"String";
}

- (NSString *)currentValue
{
    NSString    *ret = nil;
    const char  *val = arv_device_get_string_feature_value([super.device arvDeviceObject], super.fName);
    if (val != NULL)
        ret = [NSString stringWithUTF8String:val];
    return ret;
}

- (BOOL)setStringValue:(NSString *)value
{
    const char  *val = [value UTF8String];
    arv_device_set_string_feature_value([super.device arvDeviceObject], super.fName, val);
    return [self.currentValue isEqualToString:value];
}

@end


#pragma mark    *************   implementation of CoAFloatFeature ***********

@interface CoAFloatFeature ()
- (void)featureBoundsMin:(double *)min Max:(double *)max;
@end

@implementation CoAFloatFeature

+ (NSString *)genicamNodeName
{
    return @"Float";
}

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    self = [super initWithDevice:device featureName:featureName];
    if (self == nil)
        return nil;

    _unit = [super unitString];
    return self;
}

- (double)currentValue
{
    return arv_device_get_float_feature_value([super.device arvDeviceObject], super.fName);
}

- (BOOL)setFloatValue:(CGFloat)value
{
    double  min, max;
    [self featureBoundsMin:&min Max:&max];
    if ((min <= value) && (value <= max)) {
        arv_device_set_float_feature_value([super.device arvDeviceObject], super.fName, value);
        return value == self.currentValue;
    }
    return NO;
}

- (double)min
{
    double  min, max;
    [self featureBoundsMin:&min Max:&max];
    return min;
}

- (double)max
{
    double  min, max;
    [self featureBoundsMin:&min Max:&max];
    return max;
}

- (void)featureBoundsMin:(double *)min Max:(double *)max
{
    arv_device_get_float_feature_bounds([super.device arvDeviceObject], super.fName, min, max);
}

@end

#pragma mark    *************   implementation of CoAIntegerFeature ***********

@interface CoAIntegerFeature ()
- (void)featureBoundsMin:(NSInteger *)min Max:(NSInteger *)max;
@end

@implementation CoAIntegerFeature

+ (NSString *)genicamNodeName
{
    return @"Integer";
}

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    self = [super initWithDevice:device featureName:featureName];
    if (self == nil)
        return nil;
    
    _unit = [super unitString];
    return self;
}

- (NSInteger)currentValue
{
    return arv_device_get_integer_feature_value([super.device arvDeviceObject], super.fName);
}

- (BOOL)setIntegerValue:(NSInteger)value
{
    NSInteger   min, max;
    [self featureBoundsMin:&min Max:&max];
    if ((min <= value) && (value <= max)) {
        arv_device_set_integer_feature_value([super.device arvDeviceObject], super.fName, value);
        return value == self.currentValue;
    }
    return NO;
}

- (NSInteger)min
{
    NSInteger   min, max;
    [self featureBoundsMin:&min Max:&max];
    return min;
}

- (NSInteger)max
{
    NSInteger   min, max;
    [self featureBoundsMin:&min Max:&max];
    return max;
}

- (void)featureBoundsMin:(NSInteger *)min Max:(NSInteger *)max
{
    gint64  mi, mx;
    arv_device_get_integer_feature_bounds([super.device arvDeviceObject], super.fName, &mi, &mx);
    *min = mi;
    *max = mx;
}


@end


#pragma mark    *************   implementation of CoACommandFeature ***********
               
@interface CoACommandFeature ()
@end
               
@implementation CoACommandFeature

+ (NSString *)genicamNodeName
{
    return @"Command";
}

- (BOOL)execute
{
    GError  *error = NULL;
    arv_gc_command_execute((ArvGcCommand *)(super.featureNode), &error);
    return (error == NULL);
}

@end


#pragma mark    *************   implementation of CoARegisterFeature ***********

@interface CoARegisterFeature ()

@end

@implementation CoARegisterFeature

+ (NSString *)genicamNodeName
{
    return @"Register";
}

- (instancetype)initWithDevice:(CoADevice *)device featureName:(NSString *)featureName
{
    self = [super initWithDevice:device featureName:featureName];
    
    registerNodeType    t = self.type;
    return self;
}

- (registerNodeType)type
{
    registerNodeType    ret;
    switch (((ArvGcRegisterNode *)(super.featureNode))->type) {
        case ARV_GC_REGISTER_NODE_TYPE_REGISTER:
            ret = registerNodeTypeRegister;         break;
        case ARV_GC_REGISTER_NODE_TYPE_INTEGER:
            ret = registerNodeTypeInteger;          break;
        case ARV_GC_REGISTER_NODE_TYPE_MASKED_INTEGER:
            ret = registerNodeTypeMaskedInteger;    break;
        case ARV_GC_REGISTER_NODE_TYPE_FLOAT:
            ret = registerNodeTypeFloat;            break;
        case ARV_GC_REGISTER_NODE_TYPE_STRING:
            ret = registerNodeTypeString;           break;
        case ARV_GC_REGISTER_NODE_TYPE_STRUCT_REGISTER:
            ret = registerNodeTypeStructRegister;
    }
    return ret;
}

    
@end
