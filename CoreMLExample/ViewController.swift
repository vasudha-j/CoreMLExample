//
//  ViewController.swift
//  CoreMLExample
//
//  Created by Vasudha Jags on 10/24/17.
//  Copyright © 2017 Vasudha J. All rights reserved.
// Example from Lets build that app
// Add privacy camera usage in  info.plist
//Use restnet model instead of squeezenet for better results

import UIKit
import AVKit
import Vision

class ViewController: UIViewController , AVCaptureVideoDataOutputSampleBufferDelegate{

    override func viewDidLoad() {
        super.viewDidLoad()
        //Set up the camera
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        guard let captureDevice = AVCaptureDevice.default(for: .video) else { return }
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        
        captureSession.addInput(input)
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        view.layer.addSublayer(previewLayer)
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
        
       
    }

    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer =  CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        guard let model = try? VNCoreMLModel(for : SqueezeNet().model) else { return }
        
        let request = VNCoreMLRequest(model: model) { (finishedRequest, err) in
            guard let results =  finishedRequest.results as? [VNClassificationObservation] else { return }
            guard let observation = results.first else { return }
            print(finishedRequest.results)
        }
//        VNImageRequestHandler(cgImage: <#T##CGImage#>, options: <#T##[VNImageOption : Any]#>).perform(<#T##requests: [VNRequest]##[VNRequest]#>)
        
        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [ : ]).perform([request])
    }


}

