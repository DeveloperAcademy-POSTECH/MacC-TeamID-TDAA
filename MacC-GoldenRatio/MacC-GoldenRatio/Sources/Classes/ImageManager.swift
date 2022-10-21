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
    
    private let fileManager = FileManager.default
    private var cacheImages = NSCache<NSString, UIImage>()
    
    private init(){}
    
    func searchImage(url: String) -> UIImage? {
        // 메모리 캐시
        let nsString = NSString(string: url)
        if let image = cacheImages.object(forKey: nsString) {
            return image
        }

        // 디스크 캐시
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil }
        var filePathURL = URL(fileURLWithPath: path)
        
        guard let imageServerURL = URL(string: url) else { return nil }
        let imageName = imageServerURL.lastPathComponent
        filePathURL.appendPathComponent(imageName)
        
        if fileManager.fileExists(atPath: filePathURL.path) {
            guard let imageData = try? Data(contentsOf: filePathURL) else { return nil }
            guard let image = UIImage(data: imageData) else { return nil }

            cacheImages.setObject(image, forKey: nsString)
            return image
        }
        return nil
    }
    
    func cacheImage(url: String, image: UIImage) {
        // 메모리 캐시
        let nsString = NSString(string: url)
        cacheImages.setObject(image, forKey: nsString)
        
        // 디스크 캐시
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return }
        var filePathURL = URL(fileURLWithPath: path)
        
        guard let imageServerURL = URL(string: url) else { return }
        let imageName = imageServerURL.lastPathComponent
        filePathURL.appendPathComponent(imageName)
        
        guard let imageData = image.pngData() else { return }
        let imageNSData = NSData(data: imageData)
        
        imageNSData.write(to: filePathURL, atomically: true)
    }
}
