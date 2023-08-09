//
//  ImageManipulator.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 10/6/23.
//

import Foundation
import UIKit

struct ImageManipulator {
    /**
     Function that returns an image with bounding boxes drawn in appropriate places.
     
     - Parameter undrawnImage: image to be modified
     - Parameter boundingBoxes: bounding boxes to be drawn onto undrawnImage
     - Returns image with bounding boxes drawn on.
     */
    func drawBoundingBoxes(undrawnImage: UIImage, boundingBoxes: [CGRect]) -> UIImage? {
        UIGraphicsBeginImageContext(undrawnImage.size)
        undrawnImage.draw(at: .zero)
        guard let context = UIGraphicsGetCurrentContext() else {return UIImage(named: "default_image")}
        
        context.setStrokeColor(UIColor.systemYellow.cgColor)
        context.setLineWidth(5)
        context.addRects(boundingBoxes)
        context.drawPath(using: .stroke)
        
        guard let drawnImage = UIGraphicsGetImageFromCurrentImageContext() else {return UIImage(named: "default_image")}
        UIGraphicsEndImageContext()
        
        return drawnImage
    }
}

