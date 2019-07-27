//
//  AppDelegate.m
//  TestViewer
//
//  Created by decafish on 2019/07/19.
//  Copyright 2019 illusia decafish. All rights reserved.
//
//  a simple test application for Cocaravis framework

#import <Cocaravis/Cocaravis.h>
#import "AppDelegate.h"
#import "TestViewer.h"

static NSString         *RGB8PackedCurrentlyAvailableFormat = @"RGB8Packed";
static NSString         *Mono8CurrentlyAvailableFormat      = @"Mono8";

static NSString         *featureNameColumnName              = @"Feature name";
static NSString         *valueColumnName                    = @"Value";
static NSString         *typeColumnName                     = @"Type";
static NSString         *descriptionColumnName              = @"Description";

@interface AppDelegate () <CoAStreamReceiveProtocol, NSOutlineViewDataSource>
@property (weak) IBOutlet NSWindow      *window;
@property (weak) IBOutlet TestViewer    *viewer;
@property (weak) IBOutlet NSPopUpButton *cameraNames;
@property (weak) IBOutlet NSView        *selectionView;
@property (weak) IBOutlet NSPopUpButton *pixelFormatPopup;
@property (weak) IBOutlet NSTextField   *exposureTimeTextField;
@property (weak) IBOutlet NSTextField   *gainTextField;
@property (weak) IBOutlet NSOutlineView *outlineView;


@property (readonly) CoACamera          *camera;
@property (readonly) NSDictionary       *cameraProperties;
@property (readonly) CoAStream          *stream;
@property (readwrite) double            frameRate;
@property (readwrite) NSInteger         completedFrames;
@property (readwrite) NSInteger         failureCount;
@property (readwrite) NSInteger         underrunCount;


@property (readonly) CoAImageBuffer     *lastBuffer;

- (void)awareToQuitByAlert:(NSString *)messageText;
- (void)continueWithCameraSignature:(CoADeviceSignature *)deviceSignature;
- (void)receiveBufferFromFirstCamera:(CoAImageBuffer *)buffer;

- (NSString *)featureDescriptionString:(CoACameraFeature *)cf;
- (NSString *)typeColumnString:(CoACameraFeature *)cf;
- (NSString *)valueColumnString:(CoACameraFeature *)cf;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    _camera = nil;
    _cameraProperties = nil;
    _stream = nil;
    _lastBuffer = nil;
    
    self.frameRate = 0.0;
    [_pixelFormatPopup removeAllItems];
    
    CoACameraFinder *cfinder = [CoACameraFinder sharedCameraFinder];
    //  you can check connected interfaces by uncommenting the line below
    //  NSArray         *iid = cfinder.interfaceIdentifiers;
   NSArray         *cps = [cfinder connectedDevices];
    
    if ((cps == nil) || (cps.count == 0)) {
        [self awareToQuitByAlert:@"No cameras were found."];
        return;
    }
    else if (cps.count > 1) {
        [self.cameraNames removeAllItems];
        for (CoADeviceSignature *cprop in cps)
            [self.cameraNames addItemWithTitle:cprop.deviceId];
        NSAlert *selectionAlert = [[NSAlert alloc] init];
        selectionAlert.accessoryView = _selectionView;
        selectionAlert.messageText = [NSString stringWithFormat:@"%0ld cameras found:", cps.count];
        selectionAlert.informativeText = @"select from listed below...";
        [selectionAlert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
            NSInteger sel = self.cameraNames.indexOfSelectedItem;
            [self continueWithCameraSignature:cps[sel]];
        }];
    }
    else {
        [self continueWithCameraSignature:cps[0]];
    }
}

- (void)continueWithCameraSignature:(CoADeviceSignature *)deviceSignature
{
    _camera = [[CoACamera alloc] initWithDeviceSignature:deviceSignature];
    if (_camera == nil) {
        [self awareToQuitByAlert:[NSString stringWithFormat:@"Can not create camera object for %@.", deviceSignature.deviceId]];
        return;
    }
    
    //  currently, the popup is used only display, not to set pixel format
    NSArray *pxformats = _camera.availablePixelFormats;
    for (NSString *format in pxformats) {
        [self.pixelFormatPopup addItemWithTitle:format];
    }
    
    //  pixel format is forced to set because CoABuffer can not support all format types.
    NSString    *selectedFormat = nil;
    if ([pxformats containsObject:RGB8PackedCurrentlyAvailableFormat])
        selectedFormat = RGB8PackedCurrentlyAvailableFormat;
    else if ([pxformats containsObject:Mono8CurrentlyAvailableFormat])
        selectedFormat = Mono8CurrentlyAvailableFormat;
    if (selectedFormat != nil) {
        _camera.pixelFormat = selectedFormat;
        [self.pixelFormatPopup selectItemWithTitle:selectedFormat];
    }
    
    //  set camera properties to outline view
    //  it is more efficient to set them just before the panel is turned to front
    CoADevice   *device = [_camera cameraDevice];
    _cameraProperties = device.categorizedFeatures;
    _outlineView.window.title = [NSString stringWithFormat:@"Camera Properties (%@)", _camera.signature.model];
    [_outlineView reloadData];
    
/*  how to set a camera property, for example, frame rate
    id  prop = [_camera propertyByName:@"Frame rate"];
    if (prop != nil) {
        CoAFloatAcquisitionProperty *frrate = (CoAFloatAcquisitionProperty *)prop;
        frrate.currentValue = 30.0;
    }
*/

    //  it should be chacked if image size is same as camera imager size.
    //  CoACamera object forces image size to aspect ratio 4:3 in the default manner.
    //  if you want full sensor size, override the forced size.
/*
    NSSize  imageSize = _camera.regionOfInterest.size;
    NSSize  sensorSize = _camera.sensorPixelSize;
    _camera.regionOfInterest = NSMakeRect(0, 0, sensorSize.width, sensorSize.height);
 */


    //  set initial values for info & setting panel
    //  it should be better to be implemented using KVO
    CoAAcquisitionProperty  *exprop = [_camera propertyByName:[CoAExposureTimeAcquisitionProperty propertyNameString]];
    if (exprop != nil)
        [self.exposureTimeTextField setDoubleValue:((CoAExposureTimeAcquisitionProperty *)exprop).currentValue * 1000.0];
    CoAAcquisitionProperty  *gainprop = [_camera propertyByName:[CoAGainAcquisitionProperty propertyNameString]];
    if (gainprop != nil)
        [self.gainTextField setDoubleValue:((CoAGainAcquisitionProperty *)gainprop).currentValue];
    
    

    //  create stream object with buffers
    //  stream object should be created after regionOfInterest is fixed.
    //  see CoACamera.h
    NSUInteger  pooledBufferCount = 3;
    _stream = [_camera createCoAStreamWithPooledBufferCount:pooledBufferCount];
    if (_stream != nil) {
        _stream.receiver = self;
        _stream.name = @"first stream";
    }
    else {
        [self awareToQuitByAlert:[NSString stringWithFormat:@"Can not create stream object for %@.", deviceSignature.deviceId]];
        return;
    }

/*  for frame averager
    [_stream attachFrameAverager];
    [_stream.frameAverager setNewAveragingCount:3];
 */
    
    [_camera startAquisition];
}

- (void)awareToQuitByAlert:(NSString *)messageText
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = messageText;
    alert.informativeText = @"app will quit.";
    //  the application will terminate after 1 seconds
    //  wating user's awareness and giving time to put the alert sheet back.
    [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
        [NSTimer scheduledTimerWithTimeInterval:1.0
                                        repeats:NO
                                          block:^(NSTimer * _Nonnull timer) {
                                              [NSApp terminate:self];
                                          }];
    }];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification
{
    if (self.camera != nil)
        [self.camera stopAquisition];
}


#pragma mark    handle receiving streams

- (void)stream:(CoAStream *)stream receiveBuffer:(CoABuffer *)buffer
{
    if ((buffer.payloadType == CoABufferPayloadTypeImage)
        || (buffer.payloadType == CoABufferPayloadTypeMultiZoneImage)) {
        
        //  stream:receiveBuffer: method is called from a receiving thread, not main thread.
        [self performSelectorOnMainThread:@selector(receiveBufferFromFirstCamera:) withObject:(CoAImageBuffer *)buffer waitUntilDone:NO];
        //  calling a line below will cause continuous leaking of CGImage objects instead of a line above.
        //  I don't know why.
        //[self receiveBufferFromFirstCamera:(CoAImageBuffer *)buffer];
    }
}

- (void)receiveBufferFromFirstCamera:(CoAImageBuffer *)buffer
{
    CoABitmapImageRep   *irep = [CoABitmapImageRep imageRepWithImageBuffer:buffer];
    [_viewer setBitmapImageRep:irep];
    _lastBuffer = buffer;
}



#pragma mark    working camera information and setting some properties of the camera.

//  delegate method of CoAStream
- (void)streamRefreshingStatistics:(CoAStream *)stream
{
    self.frameRate = self.stream.currentFrameRate;
    self.completedFrames = self.stream.completedBufferCount;
    self.failureCount = self.stream.failureCount;
    self.underrunCount = self.stream.underrunCount;
}


- (IBAction)setExposureInMilliSec:(id)sender
{
    CoACamera   *cam;
    cam = self.camera;
    double  exposure = ((NSTextField *)sender).doubleValue * 0.001;
    CoAAcquisitionProperty  *prop = [cam propertyByName:[CoAExposureTimeAcquisitionProperty propertyNameString]];
    if (prop != nil) {
        CoAExposureTimeAcquisitionProperty  *exps = (CoAExposureTimeAcquisitionProperty *)prop;
        exps.currentValue = exposure;
        [sender setDoubleValue:exps.currentValue * 1000.0];
    }
}

- (IBAction)setGain:(id)sender
{
    double  gain = ((NSTextField *)sender).doubleValue;
    CoAAcquisitionProperty  *prop = [self.camera propertyByName:[CoAGainAcquisitionProperty propertyNameString]];
    if (prop != nil) {
        CoAGainAcquisitionProperty  *gainprop = (CoAGainAcquisitionProperty *)prop;
        gainprop.currentValue = gain;
        [sender setDoubleValue:gainprop.currentValue];
    }
}

- (IBAction)snapshot:(id)sender
{
    CoABitmapImageRep   *irep = [CoABitmapImageRep imageRepWithImageBuffer:self.lastBuffer];
    if (irep == nil) {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"No image data";
        alert.informativeText = @"Please try later";
        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
        }];
    }
    else {
        NSSavePanel *spanel = [NSSavePanel savePanel];
        spanel.allowedFileTypes = @[@"tiff"];
        spanel.title = @"save image to TIFF file.";
        [spanel beginWithCompletionHandler:^(NSModalResponse result) {
            if (result == NSModalResponseOK) {
                [[irep TIFFRepresentation] writeToURL:spanel.URL atomically:YES];
            }
        }];
    }
}



#pragma mark    for outlineview protocol to show camera properties

//  NSOutLineView is suitable to display camera properties.
//  because properties from a camera description file may be classified nested categories.
//  NSOutLineView should be selected "content mode" to "cell based"

- (id)outlineView:(NSOutlineView *)outlineView
            child:(NSInteger)index
           ofItem:(id)item
{
    if (item == nil) {
        NSArray *keys = [[self.cameraProperties allKeys] sortedArrayUsingSelector:@selector(compare:)];
        id      key = keys[index];
        return @{key:[self.cameraProperties objectForKey:key]};
    }
    id  dic = [item allObjects][0];
    if ([dic isKindOfClass:[NSDictionary class]]) {
        NSArray *keys = [[dic allKeys] sortedArrayUsingSelector:@selector(compare:)];
        id      key = keys[index];
        return @{key:[dic objectForKey:key]};
    }
    CoACameraFeature    *cf = (CoACameraFeature *)dic;
    return @{cf.name:cf};
 }


- (BOOL)outlineView:(NSOutlineView *)outlineView
   isItemExpandable:(id)item
{
    if (item == nil) {
        return YES;
    }
    id  dic = [item allObjects][0];
    return [dic isKindOfClass:[NSDictionary class]];
}

- (NSInteger)outlineView:(NSOutlineView *)outlineView
  numberOfChildrenOfItem:(id)item
{
    if (item == nil) {
        return self.cameraProperties.count;
    }
    else {
        NSDictionary    *dic = (NSDictionary *)item;
        id              obj = [dic allValues][0];
        if ([obj isKindOfClass:[NSDictionary class]])
            return ((NSDictionary *)obj).count;
    }
    return 0;
}

- (NSString *)featureDescriptionString:(CoACameraFeature *)cf
{
    NSString    *desc = cf.featureDescription;
    if ((desc == nil) || (desc.length == 0)) {
        desc = cf.displayName;
        if ((desc == nil) || (desc.length == 0)) {
            desc = cf.toolTip;
            if ((desc == nil) || (desc.length == 0)) {
                desc = @"<no detailed description>";
            }
        }
    }
    return desc;
}

- (NSString *)typeColumnString:(CoACameraFeature *)cf
{
    return [[cf class] genicamNodeName];
}

- (NSString *)valueColumnString:(CoACameraFeature *)cf
{
    NSString        *value = @"";
    if ([cf isKindOfClass:[CoABooleanFeature class]])
        value = ((CoABooleanFeature *)cf).currentValue ? @"True" : @"False";
    else if ([cf isKindOfClass:[CoAEnumerationFeature class]]) {
        NSString    *eval = ((CoAEnumerationFeature *)cf).currentValue;
        if (eval == nil)
            eval = @"(no value)";
        value = [NSString stringWithFormat:@"%@", eval];
    }
    else if ([cf isKindOfClass:[CoAStringFeature class]]) {
        NSString    *str = ((CoAStringFeature *)cf).currentValue;
        if (str != nil)
            value = [NSString stringWithFormat:@"%@", str];
    }
    else if ([cf isKindOfClass:[CoAFloatFeature class]])
        value = [NSString stringWithFormat:@"%f", ((CoAFloatFeature *)cf).currentValue];
    else if ([cf isKindOfClass:[CoAIntegerFeature class]])
        value = [NSString stringWithFormat:@"%ld", ((CoAIntegerFeature *)cf).currentValue];
    return value;
}

- (id)outlineView:(NSOutlineView *)outlineView
objectValueForTableColumn:(NSTableColumn *)tableColumn
           byItem:(id)item
{
    NSString    *title = tableColumn.title;
    if ([title isEqualToString:featureNameColumnName]) {
        return [item allKeys][0];
    }
    else {
        id  obj = [item allValues][0];
        if ([obj isKindOfClass:[NSDictionary class]])
            return @"";
        CoACameraFeature    *cf = (CoACameraFeature *)obj;
        if ([title isEqualToString:valueColumnName])
            return [self valueColumnString:cf];
        else if ([title isEqualToString:typeColumnName])
            return [self typeColumnString:cf];
        else if ([tableColumn.title isEqualToString:descriptionColumnName])
            return [self featureDescriptionString:cf];
    }
    return @"";
}

@end
