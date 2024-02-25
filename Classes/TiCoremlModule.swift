//
//  TiCoremlModule.swift
//  titanium-coreml
//
//  Created by Your Name
//  Copyright (c) 2024 Your Company. All rights reserved.
//

import UIKit
import TitaniumKit

@objc(TiCoremlModule)
class TiCoremlModule: TiModule {

  @objc public let isSupported = true
  
  func moduleGUID() -> String {
    return "eb79624b-04d4-463c-9f43-d212de1b53e3"
  }
  
  override func moduleId() -> String! {
    return "ti.coreml"
  }
}
