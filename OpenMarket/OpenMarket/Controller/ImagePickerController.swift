//
//  ImagePickerController.swift
//  OpenMarket
//
//  Created by papri, Tiana on 03/06/2022.
//

import UIKit

class ImagePickerController {
    private let imagePicker = UIImagePickerController()
    
    init(delgate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?) {
        self.setUpImagePicker(with: delgate)
    }
    
    private func setUpImagePicker(with delegate: (UIImagePickerControllerDelegate & UINavigationControllerDelegate)?) {
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.delegate = delegate
    }
    
    func pickImage(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any], updateProductViewModel: UpdateProductViewModel) {
        var newImage: UIImage? = nil
        
        if let possibleImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            newImage = possibleImage
        } else if let possibleImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            newImage = possibleImage
        }
        
        if let newImage = newImage {
            updateProductViewModel.appendImage(with: newImage)
        }
        
        picker.dismiss(animated: true)
    }
    
    func getImagePicker() -> UIImagePickerController {
        return imagePicker
    }
}
