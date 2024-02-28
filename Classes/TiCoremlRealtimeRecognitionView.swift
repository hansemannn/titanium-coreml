//
//  TiCoremlRealtimeRecognitionView.swift
//  TiCoreml
//
//  Created by Hans Knöchel on 25.02.24.
//

import CoreVideo
import TitaniumKit
import UIKit

@objc(TiCoremlRealtimeRecognitionView)
class TiCoremlRealtimeRecognitionView: TiUIView {
  
  override func frameSizeChanged(_ frame: CGRect, bounds: CGRect) {
    super.frameSizeChanged(frame, bounds: bounds)
    
    if let proxy = proxy as? TiCoremlRealtimeRecognitionViewProxy {
      proxy.adjustFrame()
    }
  }
}
