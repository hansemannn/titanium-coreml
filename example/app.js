/**
 * Ti.CoreML
 * v1.0.0 Beta
 
 * @author Hans Knöchel
 * @copyright Axway Appcelerator
 * 
 */

var CoreML = require('ti.coreml');

var recognitionView = CoreML.createRealtimeRecognitionView({
    top: 40,
    height: 300,
    model: 'Inceptionv3.mlmodelc'
});

recognitionView.addEventListener('classification', function(e) {
    Ti.API.info(e);
});

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.add(recognitionView);

var triggerButton = Ti.UI.createButton({
    bottom: 40,
    title: 'Start Real-Time Recognition'
});

triggerButton.addEventListener('click', function() {
    recognitionView.startRecognition();
});

win.add(triggerButton);
win.open();
