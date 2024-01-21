//
//  CameraView.swift
//  MaskScrollView
//
//  Created by Mike Kavouras on 6/5/16.
//  Copyright © 2016 Mike Kavouras. All rights reserved.
//

import UIKit
import AVFoundation

public class LiveCameraView: UIView, CameraDelegate {
    
    let imageView = UIImageView()
    
    public var camera = Camera()
    
    public var videoGravity: UIView.ContentMode = .scaleAspectFill {
        didSet {
            imageView.contentMode = videoGravity
        }
    }
    
    public var gesturesEnabled: Bool = true {
        didSet {
            if gesturesEnabled {
                addGestureRecognizer(doubleTapGesture)
            } else {
                removeGestureRecognizer(doubleTapGesture)
            }
        }
    }
    
    open func device() -> AVCaptureDevice? {
        return camera.device()
    }
    
    lazy private var doubleTapGesture: UITapGestureRecognizer = {
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
    
    public func captureStill(_ completion: @escaping (UIImage?) -> Void) {
        if camera.hasCamera {
            completion(imageView.image)
        } else {
            completion(nil)
        }
    }
    
    private func setup() {
        backgroundColor = UIColor.clear
        
        gesturesEnabled = true
        setupCamera()
        camera.delegate = self
        layer.masksToBounds = true
    }
    
    private func setupCamera() {
        addSubview(imageView)
        
        if #available(iOS 9.0, *) {
            layoutMargins = .zero
            let margins = layoutMarginsGuide
            imageView.leadingAnchor.constraint(equalTo: margins.leadingAnchor).isActive = true
            imageView.topAnchor.constraint(equalTo: margins.topAnchor).isActive = true
            imageView.bottomAnchor.constraint(equalTo: margins.bottomAnchor).isActive = true
            imageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor).isActive = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
        }
        
        alpha = 0.0
        camera.startStreaming()
        UIView.animate(withDuration: 0.2, delay: 0.5, options: .curveLinear, animations: {
            self.alpha = 1.0
        }, completion: nil)
    }
    
    public func flip() {
        camera.flip()
    }
    
    @objc private func handleDoubleTapGesture() {
        camera.flip()
    }
    
    override public func layoutSubviews() {
        camera.previewLayer.frame = bounds
        super.layoutSubviews()
    }
    
    func didReceiveFilteredImage(_ image: UIImage) {
        DispatchQueue.main.async {
            self.imageView.image = image
        }
    }
}
