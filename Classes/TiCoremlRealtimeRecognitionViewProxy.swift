//
//  TiCoremlRealtimeRecognitionViewProxy.swift
//  TiCoreml
//
//  Created by Hans Knöchel on 25.02.24.
//

import CoreVideo
import TitaniumKit
import UIKit
import Vision

class TiCoremlRealtimeRecognitionViewProxy: TiViewProxy {

  private var currentSampleBuffer: CVImageBuffer?
  private var previewView: UIView?
  lazy private var request: VNCoreMLRequest = {
    guard let model = try? MLModel(contentsOf: TiUtils.toURL(self.value(forKey: "model") as? String, proxy: self)) else {
      fatalError("Error creating model")
    }

    guard let visionModel = try? VNCoreMLModel(for: model) else {
      fatalError("Error creating vision model")

    }
      
    let _request = VNCoreMLRequest(model: visionModel) { request, error in
      guard let observations = request.results else {
        return
      }
      
      let result: [[String: Any]] = observations.map {
        [
          "identifier": $0.uuid,
          "confidence": $0.confidence
        ]
      }

      DispatchQueue.main.async {
        self.fireEvent("classification", with: ["classifications": result])
      }
    }
      
    _request.imageCropAndScaleOption = .centerCrop;
    
    return _request;
  }()
  
  lazy private var captureSession: TiCaptureSession = {
    let session = TiCaptureSession(completionHandler: { imageBuffer in
      self.currentSampleBuffer = imageBuffer
      self.processRecognitionWithSampleBuffer()
    })
    
    self.view.layer.addSublayer(session.previewLayer)
    self.adjustFrame()
    
    return session
  }()
  
  func adjustFrame() {
    captureSession.previewLayer.frame = view.bounds;
  }
  
  private func processRecognitionWithSampleBuffer() {
    guard let sampleBuffer = currentSampleBuffer else { return }
    let handler = VNImageRequestHandler(cvPixelBuffer: sampleBuffer)
    
    do {
      try handler.perform([request])
    } catch {
      fatalError("Error processing buffer: \(error.localizedDescription)")
    }
  }
}

// MARK: Public APIs

extension TiCoremlRealtimeRecognitionViewProxy {
  
  @objc func startRecognition(unused: Any?) {
    if captureSession.captureSession.isRunning {
      NSLog("[ERROR] Trying to start a capture session that is already running!")
      return
    }
    
    captureSession.start()
  }
  
  @objc func stopRecognition(unused: Any?) {
    if !captureSession.captureSession.isRunning {
      NSLog("[ERROR] Trying to stop a capture session that is not running!");
      return
    }
    
    captureSession.stop()
  }
  
  @objc func isRecognizing(unused: Any?) -> Bool {
    return captureSession.captureSession.isRunning
  }
  
  @objc func takePicture(value: [Any]) {
    guard let sampleBuffer = currentSampleBuffer,
          let calback = value.first as? KrollCallback else {
      return
    }
    
    let ciImage = CIImage(cvPixelBuffer: sampleBuffer)
    let context = CIContext()
    
    guard let image = context.createCGImage(ciImage, from: CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(sampleBuffer), height: CVPixelBufferGetHeight(sampleBuffer))) else {
      return
    }
    
    calback.call([["image": TiBlob(image: UIImage(cgImage: image))]], thisObject: self)
  }
}
