//
//  ViewController.swift
//  SmileMore
//
//  Created by Cory Dolphin on 1/25/16.
//  Copyright © 2016 Dolphin. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var previewLayer: AVCaptureVideoPreviewLayer?
    var session: AVCaptureSession?
    var detector: CIDetector?
    let videoDelegateQueue = dispatch_queue_create("VideoDataOutputQueue", DISPATCH_QUEUE_SERIAL)

    override func viewDidLoad() {
        super.viewDidLoad()

        let input: AVCaptureDeviceInput?
        session = AVCaptureSession()

        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        do {
            input = try AVCaptureDeviceInput(device: device)
        } catch _ {
            input = nil
        }
        session?.addInput(input)

        previewLayer = AVCaptureVideoPreviewLayer.init(session: session)
        previewLayer?.backgroundColor = CGColorGetConstantColor(kCGColorBlack)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer?.frame = self.view.layer!.bounds
        self.view.layer?.masksToBounds = true
        self.view.layer?.addSublayer(previewLayer!)

        let videoOutput = AVCaptureVideoDataOutput.init()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: videoDelegateQueue)
        session?.addOutput(videoOutput)
        session?.startRunning()
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        if detector == nil {
            // Hmm, maybe the detector needs to be allocated on the same thread it is used?
            detector = CIDetector.init(ofType: CIDetectorTypeFace, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])
        }
//        NSThread.sleepForTimeInterval(10.0)
        autoreleasepool {
            guard let buffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
                print("Buffer failed to get")
                return
            }
            let image = CIImage.init(CVImageBuffer: buffer)
            let features = detector!.featuresInImage(image, options: [CIDetectorSmile:true])
            for case let feature as CIFaceFeature in features {
                if feature.hasSmile {
                    NSLog("smiled")
                }
            }
        }
    }

}

