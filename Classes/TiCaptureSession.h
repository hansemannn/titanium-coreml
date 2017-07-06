//
//  TiCaptureSession.h
//  titanium-coreml
//
//  Created by Hans Knöchel on 05.07.17.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef void(^TiCaptureSessionCompletionHandler)(CVImageBufferRef sampleBuffer);

@interface TiCaptureSession : NSObject<AVCaptureVideoDataOutputSampleBufferDelegate> {
    UIViewController *_viewController;
    TiCaptureSessionCompletionHandler _completionHandler;
}

- (instancetype)initWithCompletionHandler:(TiCaptureSessionCompletionHandler)completionHandler;

- (void)start;

- (void)stop;

@property(nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;
@property(nonatomic, strong) AVCaptureSession *captureSession;
@property(nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property(nonatomic, strong) dispatch_queue_t queue;

@end
