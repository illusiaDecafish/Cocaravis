//
//  TestViewer.m
//  TestViewer
//
//  Created by decafish on 2019/07/19.
//  Copyright 2019 illusia decafish. All rights reserved.
//

#import "TestViewer.h"

@interface TestViewer () <CALayerDelegate>
@property (readwrite) CALayer           *bgLayer;
@property (readwrite) CALayer           *imageLayer;
@property (readwrite) NSBitmapImageRep  *imagerep;
@property (readwrite) CGImageRef        cgimage;
@property (readonly) CIContext          *context;

- (CALayer *)createNewLayerForFullView;
- (void)setNeedsDisplayOnMainThread;

@end

@implementation TestViewer

-(void)awakeFromNib
{
    //  using CALayser to display NSBitmapImageRep object
    self.wantsLayer = YES;
    
    _bgLayer = [self createNewLayerForFullView];
    CGColorRef  backColor = CGColorCreateGenericGray(0.5, 1.0);
    _bgLayer.backgroundColor = backColor;
    CGColorRelease(backColor);
    
    _cgimage = NULL;
    _imageLayer = [self createNewLayerForFullView];
    [_bgLayer addSublayer:_imageLayer];
    [self setLayer:_bgLayer];
}

- (void)setBitmapImageRep:(NSBitmapImageRep *)irep
{
    _imagerep = irep;
    //_cgimage = irep.CGImage;

    if ([[NSThread currentThread] isMainThread])
        [self setNeedsDisplayOnMainThread];
    else    //  if execution reaches the line below, memory allocation on _imagerep object will be leaked
        [self performSelectorOnMainThread:@selector(setNeedsDisplayOnMainThread) withObject:nil waitUntilDone:NO];
}

- (void)setNeedsDisplayOnMainThread
{
    [self.imageLayer setNeedsDisplay];
}

- (void)drawImageInContext:(CGContextRef)context
{
    //  autoreleasepool for CGImage should be bigger range?
    @autoreleasepool {
        NSRect  brect = self.bounds;
        CGContextSaveGState(context);
        CGContextClipToRects(context, &brect, 1);
        CGContextSetRGBFillColor(context, 0.0, 0.0, 0.0, 1.0);
        CGContextFillRect(context, brect);
        CGContextDrawImage(context, NSRectToCGRect(brect), _imagerep.CGImage);
        CGContextRestoreGState(context);
    }
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)context
{
    if (layer == _imageLayer) {
        [self drawImageInContext:context];
    }
}

- (CALayer *)createNewLayerForFullView
{
    CALayer *layer = [CALayer layer];
    layer.delegate = self;
    layer.frame = NSRectToCGRect(self.bounds);
    layer.needsDisplayOnBoundsChange = YES;
    return layer;
}

@end
