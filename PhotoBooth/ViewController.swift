//
//  ViewController.swift
//  PhotoBooth
//
//  Created by Jeff Rafter, Mike Kavouras on 1/19/18.
//  Copyright © 2018-2024. All rights reserved.
//
import UIKit
import LiveCameraView
import AVFoundation

extension Array {
    func sample() -> Element {
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}

class ViewController: UIViewController {
    
    var COUNTDOWN_PAUSE = 0.3 // 3.0
    
    var funLabel: UILabel? = nil
    
    var capturing = false {
        didSet {
            // Do something
        }
    }
    
    var captures: [UIImage] = [] {
        didSet {
            if captures.isEmpty {
                captureImageViews.forEach { $0.image = nil }
                captureStackView.isHidden = true
            } else {
                let index = captures.count - 1
                captureImageViews[index].image = captures[index]
                captureStackView.isHidden = false
            }
            
            printButton.isEnabled = captures.count == 4
            printButton.alpha = printButton.isEnabled ? 1 : 0.5
        }
    }
    
    @IBOutlet weak var captureStackView: UIStackView!
    @IBOutlet var captureImageViews: [UIImageView]!
    @IBOutlet weak var flashView: UIView!
    @IBOutlet weak var captureButton: UIButton! {
        didSet {
            captureButton.layer.cornerRadius = captureButton.frame.size.height / 2
        }
    }
    
    @IBOutlet weak var printButton: UIButton! {
        didSet {
            printButton.layer.cornerRadius = printButton.frame.size.height / 2
        }
    }
    
    var background: UIImage = UIImage(named: "Flowers4")!
    var currentPrinter: UIPrinter? = nil
    private var count = 3
    private var filterIndex = 0
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var cameraPreviewView: LiveCameraView! {
        didSet {
            cameraPreviewView.videoGravity = .scaleAspectFill
            cameraPreviewView.gesturesEnabled = false
            cameraPreviewView.transform = CGAffineTransform(scaleX: -1, y: 1);
            
            if let device = cameraPreviewView.device() {
                try! device.lockForConfiguration()
                device.exposureMode = .continuousAutoExposure
                if device.isFocusModeSupported(.continuousAutoFocus) {
                    device.focusMode = .continuousAutoFocus
                }
                device.unlockForConfiguration()
            }
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraPreviewTapped))
            cameraPreviewView.addGestureRecognizer(tapGesture)
        }
    }
    
    @objc private func cameraPreviewTapped() {
        var filters: [CIFilter?] = [
            CIFilter(name: "CIColorMonochrome"),
            CIFilter(name: "CIColorPosterize"),
            CIFilter(name: "CIFalseColor"),
            CIFilter(name: "CIPhotoEffectChrome"),
            CIFilter(name: "CIPhotoEffectFade"),
            CIFilter(name: "CIPhotoEffectInstant"),
            CIFilter(name: "CIPhotoEffectMono"),
            CIFilter(name: "CIPhotoEffectNoir"),
            CIFilter(name: "CIPhotoEffectProcess"),
            CIFilter(name: "CIPhotoEffectTonal"),
            CIFilter(name: "CIPhotoEffectTransfer"),
            CIFilter(name: "CISepiaTone"),
            CIFilter(name: "CIComicEffect"),
            CIFilter(name: "CICrystallize"),
            CIFilter(name: "CIBloom"),
            CIFilter(name: "CIHexagonalPixellate"),
            CIFilter(name: "CILineOverlay"),
            CIFilter(name: "CIPixellate"),
            CIFilter(name: "CIPointillize"),
            CIFilter(name: "CISpotColor"),
            // CIFilter(name: "CIKaleidoscope"),
            nil
        ]
        
        let filterNames = [
            "CIColorMonochrome",
            "CIColorPosterize",
            "CIFalseColor",
            "CIPhotoEffectChrome",
            "CIPhotoEffectFade",
            "CIPhotoEffectInstant",
            "CIPhotoEffectMono",
            "CIPhotoEffectNoir",
            "CIPhotoEffectProcess",
            "CIPhotoEffectTonal",
            "CIPhotoEffectTransfer",
            "CISepiaTone",
            "CIComicEffect",
            "CICrystallize",
            "CIBloom",
            "CIHexagonalPixellate",
            "CILineOverlay",
            "CIPixellate",
            "CIPointillize",
            "SpotColor",
            // "Kaleidoscope",
            ""
        ]
        print(filterNames[filterIndex % filters.count])

        
        cameraPreviewView.camera.filter = filters[filterIndex % filters.count]
        filterIndex += 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countdownLabel.alpha = 0
        printButton.isEnabled = false
        printButton.alpha = 0.5
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentPrinter == nil {
            selectPrinter()
        }
    }
    
    @IBAction func capturePhotoButtonTapped(_ sender: Any) {
        guard let _ = currentPrinter else {
            selectPrinter()
            return
        }
        
        if capturing {
          return
        }
        reset()
        capturing = true
        
        // If there is no camera we can just skip and test the layout
        if AVCaptureDevice.devices().count == 0 {
            self.captures.append(fakeImage())
            self.captures.append(fakeImage())
            self.captures.append(fakeImage())
            self.captures.append(fakeImage())
            return
        }
        
        count = 3
        showEncouragingPhrase()
    }
    
    @IBAction func printButtonTapped(_ sender: Any) {
        if self.captures.count < 4 {
            return
        }
        printImages()
        reset()
    }
    

    @objc private func showEncouragingPhrase() {
        countdownLabel.alpha = 0

        let phrases = [
            "You look great! 💁",
            "Love the camera 💗",
            "Oh yeah! ⚡️",
            "Niiiiceeeee!",
            "So cooooool! 😎",
            "Hot stuff! 🌞",
            "Beautiful! 💋",
            "Awesome! ✨",
            "Amazing!",
            "LOLOLOLOL 😂",
            "Gimme Blue Steele 🔹",
            "Gavin stole your wallet 😱"
        ]
        
        let phrase = phrases.sample()
        
        funLabel = createFunLabel(phrase)
        view.addSubview(funLabel!)

        funLabel?.frame = view.frame
        funLabel?.frame.size.width -= 40
        funLabel?.center = view.center
        funLabel?.adjustsFontSizeToFitWidth = true
        funLabel?.textAlignment = .center
        
        let timer = Timer(timeInterval: COUNTDOWN_PAUSE, target: self, selector: #selector(startCountdown), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: .default)
    }
    
    func createFunLabel(_ string: String) -> UILabel {
        let label = UILabel()
        label.font = UIFont(name: "MarkerFelt-Thin", size: 100)
        let colors = [
            UIColor.red,
            UIColor.blue,
            UIColor.green
        ]
        label.text = string
        label.textColor = colors.sample()
        return label
    }
    
    @objc private func startCountdown() {
        funLabel?.removeFromSuperview()
        countdownLabel?.removeFromSuperview()
        
        let imageContainer = captureImageViews[captures.count].superview
        imageContainer?.addSubview(countdownLabel)
        countdownLabel.frame = imageContainer!.bounds
        
        count = 4
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer(_:)), userInfo: nil, repeats: true)
        
        RunLoop.current.add(timer, forMode: .default)
        
        fireTimer(timer)
    }

    @objc private func fireTimer(_ timer: Timer) {
        if count == 4 {
            countdownLabel.text = "..."
        } else {
            countdownLabel.text = "\(count)"
        }
        countdownLabel.alpha = 1.0

        if count <= 0 {
            UIView.animate(withDuration: 0.1, animations: {
                self.flashView.alpha = 1.0
            }, completion: { _ in
                UIView.animate(withDuration: 1.0, animations: {
                    self.flashView.alpha = 0.0
                })
            })
            
            timer.invalidate()
            
            self.cameraPreviewView.captureStill { image in
                let image = image ?? self.fakeImage()
                    
                self.captures.append(image)
                if self.captures.count < 4 {
                    self.showEncouragingPhrase()
                } else {
                    self.done()
                }
                
            }

        }
        count = count - 1
    }
    
    private func fakeImage() -> UIImage {
        let name = "Dennis\(self.captures.count + 1)"
        return UIImage(named: name)!
    }
    
    private func done() {
        countdownLabel.alpha = 0
        capturing = false
        saveImages()
//        let storyboard = UIStoryboard(name: "Main", bundle: nil)
//        if let vc = storyboard.instantiateViewController(withIdentifier: "PreviewController") as? PreviewViewController {
//            vc.captures = self.captures
//            vc.currentPrinter = self.currentPrinter
//            present(vc, animated: true)
//        }
    }
    
    private func reset() {
        capturing = false
        captures = []
        count = 3
        countdownLabel.alpha = 0
    }

    
    private func saveImages() {
        for image in captures {
            if let cropped = image.square() {
                UIImageWriteToSavedPhotosAlbum(cropped, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
            }
        }
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print(error.localizedDescription)
        } else {
            print("Saved \(image)")
        }
    }
    
    
    private func selectPrinter() {
        let pickerController = UIPrinterPickerController(initiallySelectedPrinter: nil)
        pickerController.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: false, completionHandler: { (controller, picked, error) in
            self.currentPrinter = controller.selectedPrinter
        })
    }
    
    private func printImages() {
        guard let printer = currentPrinter else { return }
                        
        let printInteraction = UIPrintInteractionController.shared
        let printPageRenderer = Renderer(images: self.captures, background: self.background)
        
        // Create a print info object for the activity.
        let printInfo = UIPrintInfo.printInfo()
        printInfo.outputType = .photo
        printInfo.jobName = "PhotoBooth"
        printInteraction.printPageRenderer = printPageRenderer
        printInteraction.printInfo = printInfo
        printInteraction.print(to: printer) { (controller, printed, error) in
            self.reset()
            
            if let error = error {
                print(error)
                return
            }
        }
   
    }

}

