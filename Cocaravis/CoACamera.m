//
//  CoACamera.m
//  Cocaravis
//
//  Created by decafish on 2019/6/15.
//  Copyright illusia decafish. All rights reserved.
//

#include <arv.h>

#import "CoACamera.h"
#import "CoAStream.h"
#import "CoADevice.h"
#import "CoAFeatureCategory.h"

#define EXPOSURE_CONVERTING_RATIO               1000000
static double       exposureTimeRatioToSec      = 1.0 / EXPOSURE_CONVERTING_RATIO; //  micro sec for 0.6.3
static double       exposureTimeRatioFromSec    = 1.0 * EXPOSURE_CONVERTING_RATIO;

static NSArray      *aquisitionPropertyNameString = nil;
static NSUInteger   propertyIndexBinning;
static NSUInteger   propertyIndexFrameRate;
static NSUInteger   propertyIndexExposure;
static NSUInteger   propertyIndexGain;
static NSUInteger   propertyIndexTriggerSource;
static NSUInteger   propertyIndexTriggerMode;

static NSInteger    autoEnumFromArv(int arvAuto);
static int          autoEnumToArv(NSUInteger valueAuto);


@interface CoAPixelFormat : NSObject
@property (readwrite) ArvPixelFormat    intValue;
@property (readwrite) NSString          *formatString;
@property (readwrite) NSString          *displayName;
@end
@implementation CoAPixelFormat
@end


#pragma mark ********************** anonimous interface of CACamera ****************

@interface CoACamera ()
@property (readwrite) ArvCamera                 *arvCamera;
@property (readwrite) CoADevice                 *device;
@property (readwrite) CoAStream                 *stream;
@property (readonly) NSArray <CoAPixelFormat *> *pixelFormats;

- (NSSize)sensorSize;
- (void)setDefaultROI;
- (NSArray *)enumeratePixelFormats;
- (NSArray <NSString *> *)availablePixelFormats;
- (CoAAcquisitionProperty *)exposureProperty;
- (CoAAcquisitionProperty *)frameRateProperty;
- (CoAAcquisitionProperty *)gainProperty;
- (CoAAcquisitionProperty *)triggerSourceProperty;
- (CoAAcquisitionProperty *)triggerModeProperty;
- (CoAAcquisitionProperty *)binningProperty;


@end

@interface CoAAcquisitionProperty ()
@property (readwrite, weak) CoACamera   *camera;
@property (readwrite) NSString          *name;
@property (readwrite) NSString          *unit;
@end

@implementation CoAAcquisitionProperty

+ (NSString *)propertyNameString
{
    return nil;
}

@end

@interface CoAEnumarateAcquisitionProperty ()
@property (readwrite) NSArray           *availableValues;
@property (readwrite) NSString          *value;
@end
@implementation CoAEnumarateAcquisitionProperty
- (NSString *)currentValue
{
    return self.value;
}
- (NSString *)setNewValue:(NSString *)newValue
{
    return newValue;
}
- (void)setCurrentValue:(NSString *)value
{
    if ([self.availableValues containsObject:value]) {
        NSString    *nv = [self setNewValue:value];
        NSUInteger  index = [self.availableValues indexOfObject:nv];
        if (index != NSNotFound)
            self.value = self.availableValues[index];
    }
}
@end


@implementation CoATriggerSourceAcquisitionProperty
- (NSString *)setNewValue:(NSString *)newValue
{
    arv_camera_set_trigger_source(self.camera.arvCamera, [newValue cStringUsingEncoding:NSASCIIStringEncoding]);
    const char  *tsource = arv_camera_get_trigger_source(self.camera.arvCamera);
    return [NSString stringWithCString:tsource encoding:NSASCIIStringEncoding];
}
@end
@implementation CoATriggerModeAcquisitionProperty
- (NSString *)setNewValue:(NSString *)newValue
{
    arv_camera_set_trigger(self.camera.arvCamera, [newValue cStringUsingEncoding:NSASCIIStringEncoding]);
     return newValue;
}
@end

@interface CoAFloatAcquisitionProperty ()
@property (readwrite) double            min;
@property (readwrite) double            max;
@property (readwrite) double            value;
@end

@implementation CoAFloatAcquisitionProperty
- (double)currentValue
{
    return self.value;
}

- (double)setNewValue:(double)newValue
{
    return newValue;
}

- (void)setCurrentValue:(double)value
{
    if ((self.min <= value) && (value <= self.max))
        _value = [self setNewValue:value];
}
@end

@implementation CoAFrameRateAcquisitionProperty

+ (NSString *)propertyNameString
{
    return @"Frame rate";
}

- (double)setNewValue:(double)newValue
{
    arv_camera_set_frame_rate(self.camera.arvCamera, newValue);
    return arv_camera_get_frame_rate(self.camera.arvCamera);
}
@end

@implementation CoAExposureTimeAcquisitionProperty

+ (NSString *)propertyNameString
{
    return @"Exposure time";
}

- (double)setNewValue:(double)newValue
{
    arv_camera_set_exposure_time(self.camera.arvCamera, newValue * exposureTimeRatioFromSec);
    return arv_camera_get_exposure_time(self.camera.arvCamera) * exposureTimeRatioToSec;
}
@end

@implementation CoAGainAcquisitionProperty

+ (NSString *)propertyNameString
{
    return @"Gain";
}


- (double)setNewValue:(double)newValue
{
    arv_camera_set_gain(self.camera.arvCamera, newValue);
    return arv_camera_get_gain(self.camera.arvCamera);
}
@end

@interface CoAIntegerAcquisitionProperty ()
@property (readwrite) NSInteger         min;
@property (readwrite) NSInteger         max;
@end
@implementation CoAIntegerAcquisitionProperty
@end
@interface CoA2DIntegerAcquisitionProperty ()
@property (readwrite) NSInteger         ymin;
@property (readwrite) NSInteger         ymax;
@end
@implementation CoA2DIntegerAcquisitionProperty
@end
@implementation CoABinnigAcquisitionProperty

+ (NSString *)propertyNameString
{
    return @"Binning";
}


- (void)setBinning
{
    if ((super.min <= super.currentValue) && (super.currentValue <= super.max)
        && (self.ymin <= self.ycurrentValue) && (self.ycurrentValue <= self.ymax))
        arv_camera_set_binning(self.camera.arvCamera, (gint)(super.currentValue), (gint)(self.ycurrentValue));
}
- (void)setCurrentValue:(NSInteger)currentValue
{
    super.currentValue = currentValue;
    [self setBinning];
}
- (void)setYcurrentValue:(NSInteger)currentValue
{
    self.ycurrentValue = currentValue;
    [self setBinning];
}
@end

#pragma mark ********************** implemetation of CACamera ****************

@implementation CoACamera

+ (void)initialize
{
//  aquisitionPropertyNameString, array of implemented properties
    if (aquisitionPropertyNameString == nil) {
        aquisitionPropertyNameString = @[
                                         [CoAFrameRateAcquisitionProperty propertyNameString],
                                         [CoAExposureTimeAcquisitionProperty propertyNameString],
                                         [CoAGainAcquisitionProperty propertyNameString],
                                         [CoABinnigAcquisitionProperty propertyNameString],
                                         @"TriggerSource",
                                         @"TriggerMode"
                                        ];
        propertyIndexFrameRate = 0;
        propertyIndexExposure = 1;
        propertyIndexGain = 2;
        propertyIndexBinning = 3;
        propertyIndexTriggerSource = 4;
        propertyIndexTriggerMode = 5;
        
    }
}

+ (NSArray <NSString *> *)aquisitionPropertyNames
{
    return aquisitionPropertyNameString;
}

- (instancetype)initWithDeviceSignature:(CoADeviceSignature * __nonnull)signature
{
    self = [super init];
    
    _signature = signature;
    const char  *deviceId = [signature.deviceId cStringUsingEncoding:NSASCIIStringEncoding];
    _arvCamera = arv_camera_new(deviceId);
    
    if (_arvCamera == NULL)
        self = nil;
    /*{
        _arvCamera = (ArvCamera *)arv_gv_fake_camera_new("Fake");
         if (_arvCamera == NULL)
             self = nil;
    }*/
    
    _device = nil;
    _stream = nil;
    
    arv_camera_set_acquisition_mode(_arvCamera, ARV_ACQUISITION_MODE_CONTINUOUS);
    
    _pixelFormats = [self enumeratePixelFormats];
    _sensorPixelSize = [self sensorSize];
    NSMutableArray  *tmp = [NSMutableArray new];
    CoAAcquisitionProperty   *framerate = [self frameRateProperty];
    if (framerate != nil)
        [tmp addObject:framerate];
    CoAAcquisitionProperty   *exposure = [self exposureProperty];
    if (exposure != nil)
        [tmp addObject:exposure];
    CoAAcquisitionProperty   *gain = [self gainProperty];
    if (gain != nil)
        [tmp addObject:gain];
    CoAAcquisitionProperty   *bin = [self binningProperty];
    if (bin != nil)
        [tmp addObject:bin];
    CoAAcquisitionProperty   *tsource = [self triggerSourceProperty];
    if (tsource != nil)
        [tmp addObject:tsource];
    CoAAcquisitionProperty   *tmode = [self triggerModeProperty];
    if (tmode != nil)
        [tmp addObject:tmode];
    _acquisitionProperties = [NSArray arrayWithArray:tmp];
    
    //  this line is needed to create ArvStram object
    [self setDefaultROI];
    //CoAFrameRateAcquisitionProperty *frm = (CoAFrameRateAcquisitionProperty *)framerate;
    //frm.currentValue = 10.0;

    return self;
}

- (void)dealloc
{
    g_object_unref(self.arvCamera);
}

- (const char *)deviceID
{
    return arv_camera_get_device_id(self.arvCamera);
}

- (CoADevice *)cameraDevice
{
    if (_device == nil) {
        _device = [[CoADevice alloc] initWithCamera:self];
    }
    return _device;
}

- (NSRect)regionOfInterest
{
    gint    x;
    gint    y;
    gint    width;
    gint    height;
    arv_camera_get_region(_arvCamera, &x, &y, &width, &height);
    return NSMakeRect(x * 1.0, y * 1.0, width * 1.0, height * 1.0);
}

- (void)setRegionOfInterest:(NSRect)roi
{
    if (    (NSMinX(roi) >= 0)
        &&  (NSMinY(roi) >= 0)
        &&  (NSMaxX(roi) <= _sensorPixelSize.width)
        &&  (NSMaxY(roi) <= _sensorPixelSize.height)) {
        gint    x = (gint)(roi.origin.x);
        gint    y = (gint)(roi.origin.y);
        gint    width = (gint)(roi.size.width);
        gint    height = (gint)(roi.size.height);
        arv_camera_set_region(_arvCamera, x, y, width, height);
    }
}

//  standard display modes for 4:3 aspect
static NSSize   standard4x3PixelNumbers[] = {
    {320., 240.},
    {640., 480.},
    {800., 600.},
    {1024., 768.},
    {1280., 960.},
    {1400., 1050.},
    {1600., 1200.},
    {2048., 1536.},
    {3200., 2400.}
};


#pragma mark    setDefaultROI

//  find maximum standard size of ROI inside sensor pixel size

- (void)setDefaultROI
{
    NSRect      defaultROI = self.regionOfInterest;

    NSSize      sensor = self.sensorSize;
    //CGFloat     aspectRatio = sensor.width / sensor.height;
    NSInteger   floor = -1;
    for (NSUInteger i = 0 ; i < sizeof(standard4x3PixelNumbers) / sizeof(NSSize) ; i ++)
        if (sensor.width < standard4x3PixelNumbers[i].width) {
            floor = i - 1;
            break;
        }
    if (floor >= 0) {
        CGFloat x = (sensor.width - standard4x3PixelNumbers[floor].width) / 2.0;
        CGFloat y = (sensor.height - standard4x3PixelNumbers[floor].height) / 2.0;
        if (y < 0.0)
            y = 0.0;
        defaultROI = NSMakeRect(x, y, standard4x3PixelNumbers[floor].width, standard4x3PixelNumbers[floor].height);
    }
    [self setRegionOfInterest:defaultROI];
}

- (NSSize)sensorSize
{
    gint    width;
    gint    height;
    arv_camera_get_sensor_size(_arvCamera, &width, &height);
    return NSMakeSize(width * 1.0, height * 1.0);
}

- (NSString *)pixelFormat
{
    ArvPixelFormat  num = arv_camera_get_pixel_format(self.arvCamera);
    for (CoAPixelFormat *pf in self.pixelFormats)
        if (pf.intValue == num)
            return pf.displayName;
    return nil;
}

- (void)setPixelFormat:(NSString *)pixelFormat
{
    for (CoAPixelFormat *pf in self.pixelFormats)
        if ([pf.displayName isEqualToString:pixelFormat]) {
            arv_camera_set_pixel_format(self.arvCamera, pf.intValue);
        }
}

- (CoAAcquisitionProperty *)propertyByName:(NSString *)name
{
    for (CoAAcquisitionProperty *prop in _acquisitionProperties)
        if ([prop.name isEqualToString:name])
            return prop;
    return nil;
}

- (Class)classOfPropertyByName:(NSString *)name
{
    CoAAcquisitionProperty  *prop = [self propertyByName:name];
    return [prop class];
}

- (void)startAquisition
{
    if (self.stream != nil)
        arv_camera_start_acquisition(_arvCamera);
}

- (void)stopAquisition
{
    arv_camera_stop_acquisition(_arvCamera);
    [self.stream stopStream];
    //  self.stream = nil;
}

- (void)abortAquisition
{
    arv_camera_abort_acquisition(_arvCamera);
}

- (CoAStream *)createCoAStreamWithPooledBufferCount:(NSUInteger)count
{
//  if stream object was created once, is it will release when new one is created?

    self.stream = [[CoAStream alloc] initWithCamera:self
                                   pooledBufferSize:arv_camera_get_payload(self.arvCamera)
                                              Count:count];
/*
    self.stream = [[CoAStream alloc] initWithCamera:self
                                   pooledBufferSize:[self currentPayloadSize]
                                              Count:count];
 */
    return self.stream;
}

- (NSUInteger)currentPayloadSize
{
    return (NSUInteger)arv_camera_get_payload(self.arvCamera);
}

- (ArvStream *)createArvStream
{
    return arv_camera_create_stream(self.arvCamera, NULL, NULL);
}

- (ArvCamera *)arvCameraObject
{
    return self.arvCamera;
}

- (NSArray *)enumeratePixelFormats
{
    guint   count;
    const char  **pfstrings = arv_camera_get_available_pixel_formats_as_strings(_arvCamera, &count);
    const char  **dnames = arv_camera_get_available_pixel_formats_as_display_names(_arvCamera, &count);
    gint64      *pfs = arv_camera_get_available_pixel_formats(_arvCamera, &count);
    NSMutableArray  *temp = [[NSMutableArray alloc] initWithCapacity:count];
    for (guint i = 0 ; i < count ; i ++) {
        CoAPixelFormat   *pf = [CoAPixelFormat new];
        pf.intValue = (gint32)(pfs[i] & 0x00000000FFFFFFFF);
        pf.formatString = [NSString stringWithCString:dnames[i] encoding:NSASCIIStringEncoding];
        pf.displayName = [NSString stringWithCString:pfstrings[i] encoding:NSASCIIStringEncoding];
        [temp addObject:pf];
    }
    return [NSArray arrayWithArray:temp];
}


- (NSArray <NSString *> *)availablePixelFormats
{
    NSMutableArray  *ret = [[NSMutableArray alloc] initWithCapacity:_pixelFormats.count];
    for (NSUInteger i = 0 ; i < _pixelFormats.count ; i ++) {
        CoAPixelFormat   *pf = (CoAPixelFormat *)_pixelFormats[i];
        [ret addObject:pf.displayName];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSArray <NSString *> *)availablePropertyNames
{
    NSMutableArray  *tmp = [NSMutableArray new];
    for (CoAAcquisitionProperty *prop in self.acquisitionProperties)
        [tmp addObject:prop.name];
    return [NSArray arrayWithArray:tmp];
}

- (CoAAcquisitionProperty *)exposureProperty
{
    if (! arv_camera_is_exposure_time_available(_arvCamera))
        return nil;
    
    CoAExposureTimeAcquisitionProperty   *expp = [CoAExposureTimeAcquisitionProperty new];
    expp.name = aquisitionPropertyNameString[propertyIndexExposure];
    expp.camera = self;
    expp.unit = @"sec";
    double  min, max;
    arv_camera_get_exposure_time_bounds(_arvCamera, &min, &max);
    expp.min = min * exposureTimeRatioToSec;
    expp.max = max * exposureTimeRatioToSec;
    expp.currentValue = arv_camera_get_exposure_time(_arvCamera) * exposureTimeRatioToSec;
    if (arv_camera_is_exposure_auto_available(_arvCamera)) {
        ArvAuto aut = arv_camera_get_exposure_time_auto(_arvCamera);
        expp.valueAuto = autoEnumFromArv(aut);
    }
    else
        expp.valueAuto = autoNotImplemented;
    return expp;
}

- (CoAAcquisitionProperty *)frameRateProperty
{
    if (! arv_camera_is_frame_rate_available(_arvCamera))
        return nil;
    
    CoAFrameRateAcquisitionProperty   *frm = [CoAFrameRateAcquisitionProperty new];
    frm.name = aquisitionPropertyNameString[propertyIndexFrameRate];
    frm.camera = self;
    frm.unit = @"fps";
    double  min, max;
    arv_camera_get_frame_rate_bounds(_arvCamera, &min, &max);
    frm.min = min;
    frm.max = max;
    frm.currentValue = arv_camera_get_frame_rate(_arvCamera);
    frm.valueAuto = autoNotImplemented;
    return frm;
}

- (CoAAcquisitionProperty *)gainProperty
{
    if (! arv_camera_is_gain_available(_arvCamera))
        return nil;
    
    CoAGainAcquisitionProperty   *gain = [CoAGainAcquisitionProperty new];
    gain.name = aquisitionPropertyNameString[propertyIndexGain];
    gain.camera = self;
    gain.unit = @"dB";
    double  min, max;
    arv_camera_get_gain_bounds(_arvCamera, &min, &max);
    gain.min = min;
    gain.max = max;
    gain.currentValue = arv_camera_get_gain(_arvCamera);
    if (arv_camera_is_gain_auto_available(_arvCamera)) {
        ArvAuto aut = arv_camera_get_gain_auto(_arvCamera);
        gain.valueAuto = autoEnumFromArv(aut);
    }
    return gain;
}

- (CoAAcquisitionProperty *)triggerSourceProperty
{
    CoATriggerSourceAcquisitionProperty   *trig = [CoATriggerSourceAcquisitionProperty new];
    trig.name = aquisitionPropertyNameString[propertyIndexTriggerSource];
    trig.camera = self;
    trig.unit = @"";
    guint       count;
    const char  **tsources = arv_camera_get_available_trigger_sources(_arvCamera, &count);
    NSMutableArray  *tmp = [NSMutableArray arrayWithCapacity:count];
    for (guint i = 0 ; i < count ; i ++)
        [tmp addObject:[NSString stringWithCString:tsources[i] encoding:NSASCIIStringEncoding]];
    g_free(tsources);
    trig.availableValues = [NSArray arrayWithArray:tmp];
    NSString    *ts = [NSString stringWithCString:arv_camera_get_trigger_source(_arvCamera) encoding:NSASCIIStringEncoding];
    NSUInteger  index = [tmp indexOfObject:ts];
    if (index < count)
        trig.currentValue = [tmp objectAtIndex:index];
    return trig;
}

- (CoAAcquisitionProperty *)triggerModeProperty
{
    CoATriggerModeAcquisitionProperty   *trig = [CoATriggerModeAcquisitionProperty new];
    trig.name = aquisitionPropertyNameString[propertyIndexTriggerMode];
    trig.camera = self;
    trig.unit = @"";
    guint       count;
    const char  **triggers = arv_camera_get_available_triggers(_arvCamera, &count);
    NSMutableArray  *tmp = [NSMutableArray arrayWithCapacity:count];
    for (guint i = 0 ; i < count ; i ++)
        [tmp addObject:[NSString stringWithCString:triggers[i] encoding:NSASCIIStringEncoding]];
    g_free(triggers);
    trig.availableValues = [NSArray arrayWithArray:tmp];
    //trig.currentValue = tmp[0];
    arv_camera_clear_triggers(self.arvCamera);
    return trig;
}

- (CoAAcquisitionProperty *)binningProperty
{
    if (! arv_camera_is_binning_available(_arvCamera))
        return nil;
    
    CoA2DIntegerAcquisitionProperty   *bin = [CoA2DIntegerAcquisitionProperty new];
    bin.name = aquisitionPropertyNameString[propertyIndexBinning];
    bin.camera = self;
    bin.unit = @"pixels";
    gint    min, max;
    arv_camera_get_x_binning_bounds(_arvCamera, &min, &max);
    bin.min = min;
    bin.max = max;
    arv_camera_get_y_binning_bounds(_arvCamera, &min, &max);
    bin.ymin = min;
    bin.ymax = max;
    gint    x, y;
    arv_camera_get_binning(_arvCamera, &x, &y);
    bin.currentValue = x;
    bin.ycurrentValue = y;
    bin.valueAuto = autoNotImplemented;
    return bin;
}

- (NSString *)pixelFormatStringFromEnumValue:(NSInteger)value
{
    for (CoAPixelFormat *pxf in self.pixelFormats)
        if (pxf.intValue == value)
            return pxf.formatString;
    return nil;
}


@end



static NSInteger   autoEnumFromArv(int arvAuto)
{
    switch (arvAuto) {
        case ARV_AUTO_OFF:
            return autoOff;
        case ARV_AUTO_ONCE:
            return autoOnce;
        case ARV_AUTO_CONTINUOUS:
            return autoContinuous;
    }
    return NSNotFound;
}

static int  autoEnumToArv(NSUInteger valueAuto)
{
    switch (valueAuto) {
        case autoOff:
            return ARV_AUTO_OFF;
        case autoOnce:
            return ARV_AUTO_ONCE;
        case autoContinuous:
            return ARV_AUTO_CONTINUOUS;
        case autoNotImplemented:
            return -1;
    }
    return -1;
}
