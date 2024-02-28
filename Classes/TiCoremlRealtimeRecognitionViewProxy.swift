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

@objc(TiCoremlRealtimeRecognitionViewProxy)
class TiCoremlRealtimeRecognitionViewProxy: TiViewProxy {

  private var currentSampleBuffer: CVImageBuffer?
  private var previewView: UIView?
  lazy private var request: VNCoreMLRequest = {
    guard let url = TiUtils.toURL(self.value(forKey: "model") as? String, proxy: self) else {
      logErrorAndFail("Cannot load model from URL")
      fatalError()
    }
    
    if url.pathExtension == "modelc" {
      logErrorAndFail("Please pass the .model file, not the .modelc")
    }

    guard let model = try? MLModel(contentsOf: MLModel.compileModel(at: url)) else {
      logErrorAndFail("Error creating model")
      fatalError()
    }

    var visionModel: VNCoreMLModel!
    
    do {
      visionModel = try VNCoreMLModel(for: model)
    } catch {
      logErrorAndFail("Error creating vision model: \(error.localizedDescription)")
      fatalError()
    }

    let _request = VNCoreMLRequest(model: visionModel) { request, error in
      guard let observations = request.results as? [VNClassificationObservation] else {
        return
      }
      
      let result: [[String: Any]] = observations.map {
        [
          "identifier": $0.identifier,
          "uuid": $0.uuid.uuidString,
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
  
  private var _captureSession: TiCaptureSession!
  
  private func getCaptureSession() -> TiCaptureSession {
    guard _captureSession == nil else {
      return _captureSession
    }
    
    _captureSession = TiCaptureSession(completionHandler: { imageBuffer in
      self.currentSampleBuffer = imageBuffer
      self.processRecognitionWithSampleBuffer()
    })
    
    self.view.layer.addSublayer(_captureSession.previewLayer)
    self.adjustFrame()
    
    return _captureSession
  }
  
  func adjustFrame() {
    getCaptureSession().previewLayer.frame = view.bounds;
  }
  
  private func processRecognitionWithSampleBuffer() {
    guard let sampleBuffer = currentSampleBuffer else { return }
    let handler = VNImageRequestHandler(cvPixelBuffer: sampleBuffer)
    
    do {
      try handler.perform([request])
    } catch {
      logErrorAndFail("Error processing buffer: \(error.localizedDescription)")
    }
  }
}

// MARK: Public APIs

extension TiCoremlRealtimeRecognitionViewProxy {
  
  @objc(startRecognition:)
  func startRecognition(unused: Any?) {
    if getCaptureSession().captureSession.isRunning {
      return logErrorAndFail("Trying to start a capture session that is already running!")
    }
    
    getCaptureSession().start()
  }
  
  @objc(stopRecognition:)
  func stopRecognition(unused: Any?) {
    if !getCaptureSession().captureSession.isRunning {
      return logErrorAndFail("Trying to stop a capture session that is not running!");
    }
    
    getCaptureSession().stop()
  }
  
  @objc(isRecognizing:)
  func isRecognizing(unused: Any?) -> Bool {
    return getCaptureSession().captureSession.isRunning
  }
  
  @objc(takePicture:)
  func takePicture(value: [Any]) {
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
