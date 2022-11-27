//
//  YPImagePickerManager.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/25.
//

import UIKit
import YPImagePicker

enum YPImagePickerType {
    case multiSelectionWithCrop
}

class YPImagePickerManager {
    private var imagePickerConfig: YPImagePickerConfiguration!
    
    init(pickerType: YPImagePickerType) {
        var config = YPImagePickerConfiguration()
        
        switch pickerType {
        case .multiSelectionWithCrop:
            config.onlySquareImagesFromCamera = false
            config.albumName = "트다(TDAA)"
            config.startOnScreen = YPPickerScreen.library
            config.screens = [.library, .photo]
            config.showsCrop = .rectangle(ratio: 1)
            config.targetImageSize = YPImageSize.original
            config.library.maxNumberOfItems = 5
        }
        
        imagePickerConfig = config
    }
    
    func presentImagePicker(viewControllerToPresent: UIViewController, completion: @escaping ([UIImage]) -> Void) {
        let imagePicker = YPImagePicker(configuration: imagePickerConfig)

        imagePicker.didFinishPicking { [unowned imagePicker] items, cancelled in
            guard !cancelled else {
                print("imagePicker Cancelled")
                imagePicker.dismiss(animated: true, completion: nil)
                return
            }
            var selectedImages: [UIImage] = []
            for item in items {
                switch item {
                case .photo(let photo):
                    selectedImages.append(photo.image)
                    
                case .video(_):
                    break
                }
            }
            completion(selectedImages)
            imagePicker.dismiss(animated: true, completion: nil)
        }
        viewControllerToPresent.present(imagePicker, animated: true)
    }
}
