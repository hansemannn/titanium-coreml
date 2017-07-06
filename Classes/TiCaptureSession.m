//
//  TiCaptureSession.m
//  titanium-coreml
//
//  Created by Hans Knöchel on 05.07.17.
//

#import "TiCaptureSession.h"
#import "TiApp.h"

@implementation TiCaptureSession

- (instancetype)initWithCompletionHandler:(TiCaptureSessionCompletionHandler)completionHandler
{
    if (self = [super init]) {
        _completionHandler = completionHandler;
        _queue = dispatch_queue_create("com.axway.ti.coreml.camera-queue", NULL);
        [self setupCaptureSession];
    }
    
    return self;
}

- (void)setupCaptureSession
{
    _captureSession = [[AVCaptureSession alloc] init];
    _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
    _viewController = [[UIViewController alloc] init];
    
    [[self captureSession] beginConfiguration];
    
    [[self captureSession] setSessionPreset:AVCaptureSessionPresetMedium];
    
    AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *videoInputError = nil;
    
    if (captureDevice == nil) {
        NSLog(@"Error: Could not create capture device");
    }
    
    AVCaptureDeviceInput *videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:captureDevice error:&videoInputError];
    
    if (videoInputError != nil) {
        NSLog(@"Error: Could not create video input");
    }
    
    if ([self.captureSession canAddInput:videoInput]) {
        [[self captureSession] addInput:videoInput];
    } else {
        NSLog(@"Error: Cannot add video input to capture session");
    }
    
    _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
    _previewLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    _previewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    
    _previewLayer.frame = _viewController.view.bounds;
    [_viewController.view.layer addSublayer:_previewLayer];
    
    NSDictionary *settings = @{
        (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA]
    };
    
    _videoOutput.videoSettings = settings;
    _videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [_videoOutput setSampleBufferDelegate:self queue:_queue];
    
    if ([[self captureSession] canAddOutput:_videoOutput]) {
        [[self captureSession] addOutput:_videoOutput];
    } else {
        NSLog(@"Error: Cannot add video output to capture session");
    }
    
    [_videoOutput connectionWithMediaType:AVMediaTypeVideo];
    
    [self.captureSession commitConfiguration];
}

- (void)start
{
    [[TiApp app] showModalController:_viewController animated:YES];
    [[self captureSession] startRunning];
}

- (void)stop
{
    [_viewController dismissViewControllerAnimated:YES completion:^{
        [[self captureSession] stopRunning];
    }];
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    _completionHandler(CMSampleBufferGetImageBuffer(sampleBuffer));
}

@end
