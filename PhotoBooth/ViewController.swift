//
//  ViewController.swift
//  PhotoBooth
//
//  Created by Jeff Rafter on 1/19/18.
//  Copyright © 2018 Rplcat. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    var currentPrinter: UIPrinter? = nil

    @IBAction func printClicked(_ sender: Any) {
        guard let printer = currentPrinter else {
            selectPrinter()
            return
        }
        print(printer)
        
        guard let image = imageView.image else {
            fatalError("shareImage expects image to not be nil.")
        }
        
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
    
    func selectPrinter() {
        let pickerController = UIPrinterPickerController(initiallySelectedPrinter: nil)
        pickerController.present(from: CGRect(x: 0, y: 0, width: 0, height: 0), in: self.view, animated: false, completionHandler: { (controller, picked, error) in
            self.currentPrinter = controller.selectedPrinter
        })
    }
    
    @IBOutlet weak var imageView: UIImageView!

}

