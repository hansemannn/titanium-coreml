# iOS 11+ CoreML in Titanium
Use the native iOS CoreML" framework in the Titanium SDK.

## Requirements
- [x] Titanium SDK 12.0.0 and later
- [x] Compiled CoreML model (compile with: `xcrun coremlcompiler compile path/to/model.mlmodel /path/to/output`)

## API's

### `createRealtimeRecognitionView(args)`
- `model` (String - _Required_)

#### Methods
- `startRecognition()`
- `stopRecognition()`
- `isRecognizing()` (Boolean)

#### Events
- `classification` (`Event.classifications`)

### `isSupported()` (Boolean)

## Example

See example/app.js for details

## Compile Module

```js
ti build -p ios --build-only
```

## Legal

Copyright (c) 2017-Present by Axway Appcelerator, Inc.
Copyright (c) 2022-Present by TiDev, Inc.

All Rights Reserved. 
Usage of this module is subject to the Terms of Service agreement with Appcelerator, Inc.  
