/**
 * Appcelerator Titanium Mobile
 * Copyright (c) 2009-2017 by Appcelerator, Inc. All Rights Reserved.
 * Licensed under the terms of the Apache Public License
 * Please see the LICENSE included with this distribution for details.
 */

#import "TiCoremlRealtimeRecognitionView.h"
#import "TiCoremlRealtimeRecognitionViewProxy.h"

@implementation TiCoremlRealtimeRecognitionView

- (void)frameSizeChanged:(CGRect)frame bounds:(CGRect)bounds
{
    [(TiCoremlRealtimeRecognitionViewProxy *)[self proxy] adjustFrame];
}

@end
