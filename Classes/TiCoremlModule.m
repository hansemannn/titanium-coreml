/**
 * titanium-coreml
 *
 * Created by Hans Knoechel
 * Copyright (c) 2017 Axway Appcelerator. All rights reserved.
 */

#import "TiCoremlModule.h"
#import "TiBase.h"
#import "TiHost.h"
#import "TiUtils.h"
#import "TiCoremlRealtimeRecognitionProxy.h"

@implementation TiCoremlModule

#pragma mark Internal

- (id)moduleGUID
{
	return @"ab74a8a3-fce2-4042-8463-2049e4bdc961";
}

- (NSString *)moduleId
{
	return @"ti.coreml";
}

#pragma mark Lifecycle

- (void)startup
{
    [super startup];
	NSLog(@"[DEBUG] %@ loaded",self);
}

#pragma Public APIs

- (id)isSupported:(id)unused
{
    return NUMBOOL([TiUtils isIOSVersionOrGreater:@"11.0"]);
}

@end
