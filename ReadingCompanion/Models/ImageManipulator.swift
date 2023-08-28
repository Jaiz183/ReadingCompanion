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
//        let testRectSize = CGSize(width: undrawnImage.size.width * 0.4, height: undrawnImage.size.width * 0.4)
        // Offset by rect width and height to account for Swift's top left origin system.
//        let testRectPosition = CGPoint(x: (undrawnImage.size.width - testRectSize.width) / 2, y: (undrawnImage.size.height - testRectSize.height) / 2)
//        let testRect = CGRect(origin: testRectPosition, size: testRectSize)
        
        // Flipping around radial origin to test co-ordinate system inconsistency. This method involves moving vertical distance between radial origin and rect from origin.
        // IT WORKS!! Bounding boxes were provided in Cartesian co-ordinates, not Swift's coordinate system.
//        let transformedBoundingBox = boundingBoxes[0].offsetBy(dx: 0, dy: (undrawnImage.size.height / 2 - boundingBoxes[0].midY) * 2)
        var transformedBoundingBoxes: [CGRect] = []
        boundingBoxes.forEach { boundingBox in
            transformedBoundingBoxes.append(boundingBox.offsetBy(dx: 0, dy: (undrawnImage.size.height / 2 - boundingBox.midY) * 2))
        }
        
        UIGraphicsBeginImageContext(undrawnImage.size)
        undrawnImage.draw(at: .zero)
        guard let context = UIGraphicsGetCurrentContext() else {return UIImage(named: "default_image")}
        
        context.setStrokeColor(UIColor.systemYellow.cgColor)
        context.setLineWidth(5)
        context.addRects(transformedBoundingBoxes)
//        context.addRect(testRect)
//        context.addRect(transformedBoundingBox)
        context.drawPath(using: .stroke)
        
        guard let drawnImage = UIGraphicsGetImageFromCurrentImageContext() else {return UIImage(named: "default_image")}
        UIGraphicsEndImageContext()
        
        return drawnImage
    }
}

