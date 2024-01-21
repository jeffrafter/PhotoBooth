//
//  Camera.swift
//  TeeSnap
//
//  Created by Mike Kavouras on 5/1/16.
//  Copyright © 2016 Mike Kavouras. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraDelegate: class {
    func didReceiveFilteredImage(_ image: UIImage)
}

open class Camera: NSObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    weak var delegate: CameraDelegate?
    
    open var filter: CIFilter? = nil
    
    var hasCamera: Bool {
        return AVCaptureDevice.devices().count > 0
    }
    
    open func device() -> AVCaptureDevice? {
        return input?.device
    }
    
    var gravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            previewLayer.videoGravity = gravity
        }
    }
    
    lazy var previewLayer: AVCaptureVideoPreviewLayer = {
        let layer = AVCaptureVideoPreviewLayer(session: self.session)
        layer.backgroundColor = UIColor.clear.cgColor
        layer.videoGravity = self.gravity
        return layer
    }()
    
    private lazy var sessionQueue: DispatchQueue = {
        return DispatchQueue(label: "com.mikekavouras.LiveCameraView.capture_session")
    }()
    
    private let output = AVCaptureVideoDataOutput()
    
    private let session = AVCaptureSession()
    
    private var position: AVCaptureDevice.Position? {
        guard let input = input else { return nil }
        return input.device.position
    }
    
    private var input: AVCaptureDeviceInput? {
        guard let inputs = session.inputs as? [AVCaptureDeviceInput] else { return nil }
        return inputs.filter { $0.device.hasMediaType(AVMediaType.video) }.first
    }
    
    override init() {
        super.init()
        
        session.sessionPreset = AVCaptureSession.Preset.photo
        let queue = DispatchQueue(label: "example serial queue")
        
        output.setSampleBufferDelegate(self, queue: queue)
        checkPermissions()
    }
    
    func startStreaming() {
        showDeviceForPosition(.front)
        
        if session.canAddOutput(output) {
            session.addOutput(output)
        }
        
        let connection = output.connection(with: AVFoundation.AVMediaType.video)
        connection?.videoOrientation = .portrait
        
        sessionQueue.async { 
            self.session.startRunning()
        }
    }
    
    func flip() {
        guard let input = self.input,
            let position = self.position else { return }
        
        session.beginConfiguration()
        session.removeInput(input)
        showDeviceForPosition(position == .front ? .back : .front)
        session.commitConfiguration()
    }
//        
    private func showDeviceForPosition(_ position: AVCaptureDevice.Position) {
        guard let device = deviceForPosition(position),
            let input = try? AVCaptureDeviceInput(device: device) else {
                return
        }
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let connection = output.connection(with: AVFoundation.AVMediaType.video)
        connection?.videoOrientation = .portrait
    }
    
    private func deviceForPosition(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let allDevices = AVCaptureDevice.devices(for: AVMediaType.video)
        let relevantDevices = allDevices.filter { $0.position == position }
        
        return relevantDevices.first
    }
    
    private func checkPermissions(_ completion: (() -> Void)? = nil) {
        let authorizationStatus = AVCaptureDevice.authorizationStatus(for: AVMediaType.video)
        switch authorizationStatus {
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: AVMediaType.video,
                                                      completionHandler: { (granted:Bool) -> Void in
                                                        completion?()
            })
        case .authorized:
            completion?()
        default: return
        }
    }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension Camera {
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        if #available(iOS 9.0, *) {
            let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
            
            let image: UIImage
            if let filter = filter {
                filter.setValue(cameraImage, forKey: kCIInputImageKey)
                image = UIImage(ciImage: filter.value(forKey: kCIOutputImageKey) as! CIImage)
            } else {
                image = UIImage(ciImage: cameraImage)
            }
            
        
            delegate?.didReceiveFilteredImage(image)
        }
    }
}
