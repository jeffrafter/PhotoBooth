//
//  ViewController.swift
//  PhotoBooth
//
//  Created by Jeff Rafter on 1/19/18.
//  Copyright © 2018 Rplcat. All rights reserved.
//

import UIKit
import LiveCameraView

extension Array {
    func sample() -> Element {
        let randomIndex = Int(arc4random_uniform(UInt32(count)))
        return self[randomIndex]
    }
}

class ViewController: UIViewController {
    
    var captures: [UIImage] = []
    
    var funLabel: UILabel? = nil
    
    @IBOutlet weak var flashView: UIView!
    
    var currentPrinter: UIPrinter? = nil
    private var count = 3
    
    @IBOutlet weak var countdownLabel: UILabel!
    
    @IBOutlet weak var cameraPreviewView: LiveCameraView! {
        didSet {
            cameraPreviewView.videoGravity = .resizeAspectFill
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        reset()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if currentPrinter == nil {
            //            selectPrinter()
        }
    }
    
    @IBAction func capturePhotoButtonTapped(_ sender: Any) {
        showEncouragingPhrase()
    }

    @objc private func showEncouragingPhrase() {
        let phrases = [
            "You look great!",
            "Oh hell yeah!",
            "Nice butt!",
            "Beautiful!",
            "Awesome!",
            "LOLOLOLOL"
        ]
        
        let phrase = phrases.sample()
        
        
        funLabel = createFunLabel(phrase)
        view.addSubview(funLabel!)
        funLabel?.frame = view.frame
        funLabel?.frame.size.width -= 40
        funLabel?.center = view.center≥
        funLabel?.adjustsFontSizeToFitWidth = true
        funLabel?.textAlignment = .center
        
        let timer = Timer(timeInterval: 3.0, target: self, selector: #selector(startCountdown), userInfo: nil, repeats: false)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
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
        
        let timer = Timer(timeInterval: 1.0, target: self, selector: #selector(fireTimer(_:)), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .defaultRunLoopMode)
        
        countdownLabel.alpha = 1.0
        fireTimer(timer)
    }

    @objc private func fireTimer(_ timer: Timer) {
        countdownLabel.text = "\(count)"
    
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
                if let image = image {
                    self.captures.append(image)
                    if self.captures.count < 4 {
                        self.reset()
                        self.showEncouragingPhrase()
                    } else {
                        self.done()
                    }
                }
            }

        }
        count = count - 1
    }
    
    private func done() {
        print("done: \(captures)")
        reset()
    }

    private func printImage(_ image: UIImage?) {
        
        guard let printer = currentPrinter,
            let image = image else { return }
        
        let printInteraction = UIPrintInteractionController.shared
        let printPageRenderer = Renderer(image: image)
        
        // Create a print info object for the activity.
        let printInfo = UIPrintInfo.printInfo()
        
        /*
         This application prints photos. UIKit will pick a paper size and print
         quality appropriate for this content type.
         */
        printInfo.outputType = .photo
        
        // Use the name from the image metadata we've set.
        printInfo.jobName = "Horse"
        printInteraction.printPageRenderer = printPageRenderer
        
        printInteraction.printInfo = printInfo
        printInteraction.print(to: printer) { (controller, printed, error) in
            if let error = error {
                print(error)
                return
            }
        }
    }
    
    private func selectPrinter() {
        let pickerController = UIPrinterPickerController(initiallySelectedPrinter: nil)
        pickerController.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: false, completionHandler: { (controller, picked, error) in
            self.currentPrinter = controller.selectedPrinter
        })
    }
    
    private func reset() {
        countdownLabel.alpha = 0
        count = 3
    }
}

