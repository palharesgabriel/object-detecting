# Detecting dominant objects in a scene.
iOS sample project to demonstrate the use of CoreML Models.

The project uses the Resnet50 model provided by Apple [here](https://developer.apple.com/machine-learning/models/). This model is used to detect the dominant object of a scene.

This application uses the camera and capture the frames to perform the real-time classification. To do this you need to use the ```AVKit``` framework and start an ```AVCaptureSession()```.

After setting AVCaptureDevice and ```AVCaptureDeviceInput``` we need to implement ```AVCaptureVideoDataOutputSampleBufferDelegate``` to access the sample buffer, which is the output with the frames, but to apply the model we need to convert that output to a ```CVPixelBuffer```.

```swift
guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
```
Finally we can apply the classification method in the captured image. In this project the ```Vision ``` framework is used, so we first created a ```VNCoreMLModel``` passing our ```Resnet50``` as parameter, with this model we created a ```VNCoreMLRequest``` and sent this request with the ```pixelBuffer``` to classify our object.

```swift
 guard let model = try? VNCoreMLModel(for: Resnet50().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedEq, err) in
            
            if err != nil {
                print(err!)
            }
            
            guard let results = finishedEq.results as? [VNClassificationObservation] else { return }
            guard let firstObservation = results.first else { return }
            
            DispatchQueue.main.async {
                self.resultLabel.text = "\(firstObservation.identifier), \(firstObservation.confidence)"
            }
        }
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request])
```

I am very excited about the possibilities and facilities provided by the frameworks CreateML and CoreML to apply Machine Learning in solving various problems, I intend to continue with this study.


## License

The project does not need a license :)
