//
//  TiCoremlRealtimeRecognitionProxy.h
//  titanium-coreml
//
//  Created by Hans Knöchel on 05.07.17.
//

#if IS_IOS_11

#import "TiProxy.h"
#import "TiCaptureSession.h"

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

@interface TiCoremlRealtimeRecognitionProxy : TiProxy {
    @private
    TiCaptureSession *_captureSession;
    UIView *_previewView;
    VNCoreMLRequest *_request;
}

@end

#endif
