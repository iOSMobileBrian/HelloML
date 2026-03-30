//
//  ImagePickerCamera.swift
//  HelloML
//
//  Created by Brian Surface on 3/29/26.
//

import Foundation
import SwiftUI

struct ImagePickerCamera: UIViewControllerRepresentable {
    
    @Environment(\.dismiss) var dismiss
    typealias UIViewControllerType = UIImagePickerController
    typealias Coordinator = ImagePickerCoodinator
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType = .camera
    
    func makeCoordinator() -> Coordinator {
        return ImagePickerCoodinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.allowsEditing = false
        picker.delegate = context.coordinator
        picker.sourceType = sourceType
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        
    }
    
    
    
    class ImagePickerCoodinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var parent: ImagePickerCamera
        
        init(parent: ImagePickerCamera) {
            self.parent = parent
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            self.image = image
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss()
    }
}
