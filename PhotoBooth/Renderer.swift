/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 `UIPrintPageRenderer` subclass for drawing an image for print.
 */

import UIKit

extension UIImage {
    func square() -> UIImage? {
        if size.width == size.height {
            return self
        }
        
        let cropWidth = min(size.width, size.height)
        
        let rect = CGRect(
            x: (size.width - cropWidth) / 2.0,
            y: (size.height - cropWidth) / 2.0,
            width: cropWidth,
            height: cropWidth
        )

        UIGraphicsBeginImageContextWithOptions(rect.size, false, self.scale)
        self.draw(at: CGPoint(x: -rect.origin.x, y: -rect.origin.y))
        let cropped = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cropped
    }
}

/// A `UIPrintPageRenderer` subclass to print an image.
class Renderer: UIPrintPageRenderer {
    // MARK: Properties
    
    var images: [UIImage]
    var background: UIImage
    
    // MARK: Initilization
    
    init(images: [UIImage], background: UIImage) {
        self.images = images
        self.background = background
    }
    
    // MARK: UIPrintPageRenderer Overrides
    override var numberOfPages: Int {
        return 1
    }
    
    override func drawPage(at pageIndex: Int, in printableRect: CGRect) {
        drawStripsPage(at: pageIndex, in: printableRect)
    }
    
    func drawStripsPage(at pageIndex: Int, in printableRect: CGRect) {
        print(printableRect)
        print(paperRect)
        
        let width = printableRect.width
        let height = printableRect.height
        
        let imageWidth = CGFloat(96.0)
        let imageHeight = CGFloat(96.0)

        // Draw the background image first and make it aspect fill for the page
        let bg = background
        let bgWidth = bg.size.width
        let bgHeight = bg.size.height
        let bgRatio = bgWidth / bgHeight
        let bgRect: CGRect
        if bgRatio > 1 {
            let bgHeight = height
            let bgWidth = bgHeight * bgRatio
            bgRect = CGRect(x: (width - bgWidth) / 2, y: 0, width: bgWidth, height: bgHeight)
        } else {
            let bgWidth = width
            let bgHeight = bgWidth / bgRatio
            bgRect = CGRect(x: 0, y: (height - bgHeight) / 2, width: bgWidth, height: bgHeight)
        }
        bg.draw(in: bgRect)
        
        // Two photos across like: [ space PHOTO space | space PHOTO space ]
        let horzSpace = (width - (2 * imageWidth) - 1) / 4
        // Four photos down like [ space PHOTO PHOTO PHOTO PHOTO space ]
        let vertSpace = (height - (4 * imageHeight)) / 2
        
        var index = CGFloat(0)
        
        for image in images {
            if let cropped = image.square() {
                let left = CGRect(x: horzSpace, y: vertSpace + (imageHeight * index), width: imageWidth, height: imageHeight)
                cropped.draw(in: left)
                
                let right = CGRect(x: (horzSpace * 3) + imageWidth + 1, y: vertSpace + (imageHeight * index), width: imageWidth, height: imageHeight)
                cropped.draw(in: right)
                print("Index: \(index)")
                print(cropped)
                print("Left: \(left)")
                print("Right: \(right)")
            }
            index += 1
        }
        print("done")
    }
    
    func drawVignettePage(at pageIndex: Int, in printableRect: CGRect) {
        /*
         When `drawPageAtIndex(_:inRect:)` is invoked, `paperRect` reflects the
         size of the paper we are printing on and `printableRect` reflects the
         rectangle describing the imageable area of the page, that is the portion
         of the page that the printer can mark without clipping.
         */
        let paperSize = paperRect.size
        let imageableAreaSize = printableRect.size
        
        /*
         If `paperRect` and `printableRect` are the same size, the sheet is
         borderless and we will use the fill algorithm. Otherwise we will uniformly
         scale the image to fit the imageable area as close as is possible without
         clipping.
         */
        let fillsSheet = paperSize == imageableAreaSize
        
        guard let image = images.first else {
            return
        }
        
        let imageSize = image.size
        
        let destinationRect: CGRect
        if fillsSheet {
            destinationRect = CGRect(origin: .zero, size: paperSize)
        }
        else {
            destinationRect = printableRect
        }
        
        /*
         Calculate the ratios of the destination rectangle width and height to
         the image width and height.
         */
        let widthScale = destinationRect.width / imageSize.width
        let heightScale = destinationRect.height / imageSize.height
        
        // Scale the image to have some padding within the page.
        let scale: CGFloat
        
        if fillsSheet {
            // Produce a fill to the entire sheet and clips content.
            scale = (widthScale > heightScale ? widthScale : heightScale)
        }
        else {
            // Show all the content at the expense of additional white space.
            scale = (widthScale < heightScale ? widthScale : heightScale)
        }
        
        /*
         Compute the coordinates for `centeredDestinationRect` so that the scaled
         image is centered on the sheet.
         */
        let printOriginX = (paperSize.width - imageSize.width * scale) / 2
        let printOriginY = (paperSize.height - imageSize.height * scale) / 2
        let printWidth = imageSize.width * scale
        let printHeight = imageSize.height * scale
        
        let printRect = CGRect(x: printOriginX, y: printOriginY, width: printWidth, height: printHeight)
        
        // Inset the printed image by 10% of the size of the image.
        let inset = max(printRect.width, printRect.height) * 0.1
        let insettedPrintRect = printRect.insetBy(dx: inset, dy: inset)
        
        // Create the vignette clipping.
        let context = UIGraphicsGetCurrentContext()!
        context.addEllipse(in: insettedPrintRect)
        context.clip()
        
        image.draw(in: insettedPrintRect)
    }
}

