//
//  ViewController.swift
//  MachineLearning
//
//  Created by Gabriel Palhares on 02/07/19.
//  Copyright © 2019 Gabriel Palhares. All rights reserved.
//

import UIKit
import AVKit
import Vision

class ViewController: UIViewController {
    
    let captureSession = AVCaptureSession()
    
    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // start up the camera
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        captureSession.startRunning()
        captureSession.sessionPreset = .photo
        
        // adding the camera layer in the view
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        // setting the buffer delegate
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
        self.setupLabel()
    }
    
    func setupLabel() {
        self.view.addSubview(resultLabel)
        self.resultLabel.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.resultLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16).isActive = true
        self.resultLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16).isActive = true
    }
    


}

extension ViewController : AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
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
    }
}

