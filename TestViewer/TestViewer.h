//
//  TestViewer.h
//  TestViewer
//
//  Created by decafish on 2019/07/19.
//  Copyright 2019 illusia decafish. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface TestViewer : NSView

//  this method should be called on the main thread
//  because memory for CGImage will be leaked
//  I don't know why and how to avoid.
- (void)setBitmapImageRep:(NSBitmapImageRep *)irep;

@end

NS_ASSUME_NONNULL_END
