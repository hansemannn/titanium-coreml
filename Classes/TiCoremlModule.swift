//
//  TiCoremlModule.swift
//  titanium-coreml
//
//  Created by Your Name
//  Copyright (c) 2024 Your Company. All rights reserved.
//

import AVFoundation
import UIKit
import TitaniumKit

func logErrorAndFail(_ message: String) {
  NSLog("[ERROR] \(message)")
  fatalError(message)
}

@objc(TiCoremlModule)
class TiCoremlModule: TiModule {
  
  func moduleGUID() -> String {
    return "eb79624b-04d4-463c-9f43-d212de1b53e3"
  }
  
  override func moduleId() -> String! {
    return "ti.coreml"
  }
  
  @objc(isSupported:)
  func isSupported(unused: Any?) -> Bool {
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      return false
    }
    
    guard let _ = try? AVCaptureDeviceInput(device: captureDevice) else {
      return false
    }
    
    return true
  }
}
