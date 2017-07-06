//
//  TiCoremlRealtimeRecognitionProxy.m
//  titanium-coreml
//
//  Created by Hans Knöchel on 05.07.17.
//

#if IS_IOS_11

#import "TiCoremlRealtimeRecognitionViewProxy.h"
#import "TiUtils.h"

@implementation TiCoremlRealtimeRecognitionViewProxy

#pragma mark Internal

- (TiCaptureSession *)captureSession
{
    if (_captureSession == nil) {
        _captureSession = [[TiCaptureSession alloc] initWithCompletionHandler:^(CVImageBufferRef sampleBuffer) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                _currentSampleBuffer = sampleBuffer;
            });
            [self processRecognitionWithSampleBuffer:sampleBuffer];
        }];
        
        AVCaptureVideoPreviewLayer *previewLayer = [_captureSession previewLayer];
        
        [[[self view] layer] addSublayer:previewLayer];
        [self adjustFrame];
    }
    
    return _captureSession;
}

- (void)adjustFrame
{
    [_captureSession previewLayer].frame = [self view].bounds;
}

- (VNCoreMLRequest *)request
{
    if (_request == nil) {
        // Setup CoreML model
        NSError *visionModelError = nil;
        NSError *modelError = nil;
        MLModel *model = [MLModel modelWithContentsOfURL:[TiUtils toURL:[self valueForKey:@"model"] proxy:self]
                                                   error:&modelError];
        
        if (modelError != nil) {
            [self throwException:@"Error creating model" subreason:[modelError localizedDescription] location:CODELOCATION];
        }
        
        // Setup Vision CoreML model
        VNCoreMLModel *visionModel = [VNCoreMLModel modelForMLModel:model
                                                              error:&visionModelError];
        
        if (visionModelError != nil) {
            [self throwException:@"Error creating vision model" subreason:[visionModelError localizedDescription] location:CODELOCATION];
        }
        
        // Setup Vision CoreML request
        _request = [[VNCoreMLRequest alloc] initWithModel:visionModel completionHandler:^(VNRequest *request, NSError *error) {
            NSArray<VNClassificationObservation *> *observations = [request results];
            
            NSMutableArray<NSDictionary<NSString *, id> *> *result = [NSMutableArray arrayWithCapacity:[observations count]];
            
            for (VNClassificationObservation *observation in observations) {
                [result addObject:@{
                    @"identifier": observation.identifier,
                    @"confidence": NUMFLOAT(observation.confidence),
                }];
            }
            TiThreadPerformOnMainThread(^{
                [self fireEvent:@"classification" withObject:@{@"classifications": result}];
            }, NO);
        }];
        
        _request.imageCropAndScaleOption = VNImageCropAndScaleOptionCenterCrop;
    }
    
    return _request;
}

- (void)processRecognitionWithSampleBuffer:(CVImageBufferRef)sampleBuffer
{
    NSError *handlerError = nil;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCVPixelBuffer:sampleBuffer options:@{}];
    
    [handler performRequests:@[[self request]] error:&handlerError];
    
    if (handlerError != nil) {
        NSLog([NSString stringWithFormat:@"[ERROR] Error processing buffer: %@", [handlerError localizedDescription]]);
    }
}

#pragma mark Public API's

- (void)startRecognition:(id)unused
{
    if (![[[self captureSession] captureSession] isRunning]) {
        [[self captureSession] start];
    } else {
        NSLog(@"[ERROR] Trying to start a capture session that is already running!");
    }
}

- (void)stopRecognition:(id)unused
{
    if ([[[self captureSession] captureSession] isRunning]) {
        [[self captureSession] stop];
    } else {
        NSLog(@"[ERROR] Trying to stop a capture session that is not running!");
    }
}

- (id)isRecognizing:(id)unused
{
    return NUMBOOL([[[self captureSession] captureSession] isRunning]);
}

- (void)takePicture:(id)value
{
    ENSURE_SINGLE_ARG(value, KrollCallback);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:_currentSampleBuffer];
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef image = [context createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(_currentSampleBuffer), CVPixelBufferGetHeight(_currentSampleBuffer))];
    
    [(KrollCallback*)value call:@[@{@"image": [[TiBlob alloc] initWithImage:[UIImage imageWithCGImage:image]]}] thisObject:self];
}

@end

#endif
