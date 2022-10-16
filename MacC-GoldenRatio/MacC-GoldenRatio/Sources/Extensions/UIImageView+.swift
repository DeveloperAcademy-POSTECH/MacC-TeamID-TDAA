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
			self.kf.setImage(with: url)
		}
	}
}
