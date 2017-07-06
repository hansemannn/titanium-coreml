var CoreML = require('ti.coreml');

var Recognition = CoreML.createRealtimeRecognition({
    model: 'Inceptionv3.mlmodelc'
});

Recognition.addEventListener('classification', function(e) {
    Ti.API.info(e);
});

var win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

var btn = Ti.UI.createButton({
    title: 'Start Real-Time Recognition'
});

btn.addEventListener('click', function() {
    Recognition.startRecognition();
});

win.add(btn);
win.open();
