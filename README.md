# iOS 11+ CoreML in Titanium
Use the native iOS 11+ "CoreML" framework in Axway Titanium.

## Requirements
- [x] Titanium SDK 6.2.0 and later
- [x] iOS 11 and later
- [x] Compiled CoreML models (`xcrun coremlcompiler compile path/to/model.mlmodel /path/to/output`)

## API's

### `createRealtimeRecognition(args)`
- `model` (String - _Required_)

#### Methods
- `startRecognition()`
- `stopRecognition()`

#### Events
- `classification`
  - `classifications` (Array<Object>)
    - `identifier` (String)
    - `classification` (Float)

## Example
```js
var CoreML = require('ti.coreml');

var Recognition = CoreML.createRealtimeRecognition({
    model: 'Inceptionv3.mlmodelc' // Compiled .mlmodel
});

Recognition.addEventListener('classification', function(e) {
    Ti.API.info(e);
});

Recognition.startRecognition();
```

## Build
```js
cd iphone
appc ti build -p ios --build-only
```

## Legal

This module is Copyright (c) 2017-Present by Axway Appcelerator, Inc. All Rights Reserved. 
Usage of this module is subject to the Terms of Service agreement with Appcelerator, Inc.  
