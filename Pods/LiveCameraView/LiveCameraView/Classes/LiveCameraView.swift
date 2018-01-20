//
//  CameraView.swift
//  MaskScrollView
//
//  Created by Mike Kavouras on 6/5/16.
//  Copyright © 2016 Mike Kavouras. All rights reserved.
//

import UIKit
import AVFoundation

open class LiveCameraView: UIView {
    
    @IBInspectable
    open var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            camera.gravity = videoGravity
        }
    }
    
    open var gesturesEnabled: Bool = true {
        didSet {
            if gesturesEnabled {
                addGestureRecognizer(doubleTapGesture)
            } else {
                removeGestureRecognizer(doubleTapGesture)
            }
        }
    }
    
    fileprivate let camera = Camera()
    
    lazy fileprivate var doubleTapGesture: UITapGestureRecognizer = {
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(LiveCameraView.handleDoubleTapGesture))
        doubleTap.numberOfTapsRequired = 2
        return doubleTap
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    open func captureStill(_ completion: @escaping (UIImage?) -> Void) {
        camera.capturePreview { (image) in
            completion(image)
        }
    }
    
    fileprivate func setup() {
        backgroundColor = UIColor.clear
        
        gesturesEnabled = true
        setupCamera()
        camera.gravity = videoGravity
    }
    
    fileprivate func setupCamera() {
        layer.addSublayer(camera.previewLayer)
        
        alpha = 0.0
        camera.startStreaming()
        UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveLinear, animations: {
                self.alpha = 1.0
            }, completion: nil)
    }
    
    open func flip() {
        camera.flip()
    }
    
    @objc fileprivate func handleDoubleTapGesture() {
        camera.flip()
    }
    
    override open func layoutSubviews() {
        camera.previewLayer.frame = bounds
        super.layoutSubviews()
    }
    

}
