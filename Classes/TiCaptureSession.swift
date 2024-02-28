//
//  TiCaptureSession.swift
//  TiCoreml
//
//  Created by Hans Knöchel on 25.02.24.
//

import UIKit
import AVFoundation
import CoreVideo

typealias TiCaptureSessionCompletionHandler = (CVImageBuffer) -> Void

class TiCaptureSession: NSObject {
  
  let queue = DispatchQueue(label: "io.tidev.coreml.camera-queue")
  let completionHandler: TiCaptureSessionCompletionHandler
  let captureSession = AVCaptureSession()
  let videoOutput = AVCaptureVideoDataOutput()

  var previewLayer: AVCaptureVideoPreviewLayer!
  
  init(completionHandler: @escaping TiCaptureSessionCompletionHandler) {
    self.completionHandler = completionHandler

    super.init()

    self.setupCaptureSession()
  }
  
  private func setupCaptureSession() {
    captureSession.beginConfiguration()
    captureSession.sessionPreset = .photo
    
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      return logErrorAndFail("Could not create capture device")
    }
    
    guard let videoInput = try? AVCaptureDeviceInput(device: captureDevice) else {
      return logErrorAndFail("Could not create video input")
    }
    
    guard captureSession.canAddInput(videoInput) else {
      return logErrorAndFail("Could not add video input to capture session")
    }
    
    captureSession.addInput(videoInput)
    
    previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
    previewLayer.videoGravity = .resizeAspect

//    if #available(iOS 17.0, *) {
//      previewLayer.connection?.videoRotationAngle = 90
//    } else {
      previewLayer.connection?.videoOrientation = .portrait
//    }
    
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    videoOutput.alwaysDiscardsLateVideoFrames = true
    videoOutput.setSampleBufferDelegate(self, queue: queue)
    
    guard captureSession.canAddOutput(videoOutput) else {
      return logErrorAndFail("Could not add video output to capture session")
    }
    
    captureSession.addOutput(videoOutput)

    let _ = videoOutput.connection(with: .video)
    captureSession.commitConfiguration()
  }
  
  func start() {
    captureSession.startRunning()
  }
  
  func stop() {
    captureSession.stopRunning()
  }
}

// MARK: AVCaptureVideoDataOutputSampleBufferDelegate

extension TiCaptureSession: AVCaptureVideoDataOutputSampleBufferDelegate {

  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    if let image = CMSampleBufferGetImageBuffer(sampleBuffer) {
      completionHandler(image)
    }
  }
}
