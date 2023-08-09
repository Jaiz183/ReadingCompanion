//
//  DocumentCamera.swift
//  ReadingCompanion
//
//  Created by Jaiz Jeeson on 24/7/23.
//

import Foundation
import VisionKit
import SwiftUI

class DocumentCameraCoordinator: NSObject, VNDocumentCameraViewControllerDelegate {
    var parent: DocumentCamera
    
    init(parent: DocumentCamera) {
        self.parent = parent
    }
    
    func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        var scannedImages: [UIImage] = []
        
        for i in 0..<scan.pageCount {
            scannedImages.append(scan.imageOfPage(at: i))
        }
        
        self.parent.scannedImages = scannedImages
        self.parent.isTextRecognitionComplete = false
        controller.dismiss(animated: true)
    }
}

struct DocumentCamera: UIViewControllerRepresentable {
    @Binding var scannedImages: [UIImage]
    @Binding var isTextRecognitionComplete: Bool
    
    typealias UIViewControllerType = VNDocumentCameraViewController
    typealias Coordinator = DocumentCameraCoordinator
    
    func makeCoordinator() -> DocumentCamera.Coordinator {
        return DocumentCameraCoordinator(parent: self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<DocumentCamera>) -> DocumentCamera.UIViewControllerType {
        let documentCameraViewController = VNDocumentCameraViewController()
        documentCameraViewController.delegate = context.coordinator
        return documentCameraViewController
    }
    
    func updateUIViewController(_ uiViewController: VNDocumentCameraViewController, context: Context) {
    }
}
