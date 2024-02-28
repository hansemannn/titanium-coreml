import CoreML from 'ti.coreml';

let recognitionView, triggerButton;

const win = Ti.UI.createWindow({
    backgroundColor: '#fff'
});

win.addEventListener('close', () => {
    if (recognitionView?.isRecognizing()) {
        recognitionView.stopRecognition();
    }
})

const ButtonState = {
    Start: 'Start Real-Time Recognition',
    Stop: 'Stop Real-Time Recognition'
};

win.addEventListener('open', () => {
    if (!CoreML.isSupported()) {
        triggerButton.applyProperties({ title: '❌ Device not supported', enabled: false });
        return;
    }

    recognitionView = CoreML.createRealtimeRecognitionView({
        top: 40,
        height: 300,
        model: 'Inceptionv3.mlmodel'
    });
    
    recognitionView.addEventListener('classification', ({ classifications }) => {
        Ti.API.info(classifications); // Optionally sort by confidence and only log if >= threshold
    });
})

triggerButton = Ti.UI.createButton({
    bottom: 40,
    title: ButtonState.Start
});

triggerButton.addEventListener('click', () => {
    if (!recognitionView.isRecognizing()) {
        recognitionView.startRecognition();
        triggerButton.title = ButtonState.Stop;
        win.add(recognitionView);
    } else {
        recognitionView.stopRecognition();
        triggerButton.title = ButtonState.Start;
        win.remove(recognitionView);
    }
});

win.add(triggerButton);
win.open();
