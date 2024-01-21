//
//  PreviewViewController.swift
//  PhotoBooth
//
//  Created by Jeff Rafter on 1/20/24.
//  Copyright © 2024 Rplcat. All rights reserved.
//

import UIKit

class PreviewViewController: UIViewController {
    var captures: [UIImage] = [] {
        didSet {
            captureImages[0]
        }
    }
    var currentPrinter: UIPrinter? = nil
    var background: UIImage = UIImage(named: "Beach")!
    
    func reset() {
        dismiss(animated: true)
    }
    
    @IBOutlet var captureImages: [UIImageView]!

    @IBAction func printButtonTapped(_ sender: Any) {
        printImages()
        reset()
    }
    
    @IBAction func shootButtonTapped(_ sender: Any) {
        reset()
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
