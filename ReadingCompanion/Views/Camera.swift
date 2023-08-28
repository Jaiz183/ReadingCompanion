//
//  Camera.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 31/5/23.
//

import Foundation
import SwiftUI

class CameraCoordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    @Binding var image: UIImage?
    @Binding var isTextRecognitionComplete: Bool
    
    init(image: Binding<UIImage?>, isTextRecognitionComplete: Binding<Bool>) {
        _image = image
        _isTextRecognitionComplete = isTextRecognitionComplete
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Access taken image and set as image.
        if let imageFromUI = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = imageFromUI
            self.isTextRecognitionComplete = false
        }
        
        picker.dismiss(animated: false, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: false, completion: nil)
    }
}

struct Camera: UIViewControllerRepresentable {
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = CameraCoordinator
    @Binding var image: UIImage?
    @Binding var isTextRecognitionComplete: Bool
    
    
    func makeCoordinator() -> Camera.Coordinator {
        return CameraCoordinator(image: self.$image, isTextRecognitionComplete: self.$isTextRecognitionComplete)
    }
    
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<Camera>) -> Camera.UIViewControllerType {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = context.coordinator
        return imagePickerController
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Camera>) {
        
    }
}
