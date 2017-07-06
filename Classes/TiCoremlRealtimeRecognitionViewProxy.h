//
//  TiCoremlRealtimeRecognitionProxy.h
//  titanium-coreml
//
//  Created by Hans Knöchel on 05.07.17.
//

#if IS_IOS_11

#import "TiViewProxy.h"
#import "TiCaptureSession.h"

#import <CoreML/CoreML.h>
#import <Vision/Vision.h>

@interface TiCoremlRealtimeRecognitionViewProxy : TiViewProxy {
    @private
    TiCaptureSession *_captureSession;
    UIView *_previewView;
    VNCoreMLRequest *_request;
    CVImageBufferRef _currentSampleBuffer;
}

- (void)adjustFrame;

#pragma mark Public API's

- (void)startRecognition:(id)unused;

- (void)stopRecognition:(id)unused;

- (id)isRecognizing:(id)unused;

- (void)takePicture:(id)value;

@end

#endif
