//
//  ImageManager.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/13.
//

import UIKit

// TODO: 로컬 캐싱 처리
class ImageManager {
    static let shared = ImageManager()
    
    var cacheImages: [String:UIImage] = [:]
    
    func searchImage(url: String) -> UIImage? {
        return cacheImages[url]
    }
    
    func cacheImage(url: String, image: UIImage) {
        cacheImages[url] = image
    }
}
