//
//  UIImageView+.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/11.
//

import FirebaseStorage
import UIKit

extension UIImageView {
	func setImage(with urlString: String) {
        if let image = ImageManager.shared.searchImage(url: urlString){
            self.image = image
        }else{
            let storage = Storage.storage()
            storage.reference(forURL: urlString).downloadURL { (url, error) in
                if let error = error {
                    print("An error has occured: \(error.localizedDescription)")
                    return
                }
                if urlString == "" {
                    return
                }
                guard let url = url else {
                    return
                }
                Task{
                    self.kf.setImage(with: url)
                    ImageManager.shared.cacheImage(url: urlString, image: self.image ?? UIImage())
                }
            }
        }
		
	}
}
