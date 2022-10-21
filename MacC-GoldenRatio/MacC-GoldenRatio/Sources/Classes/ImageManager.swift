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
    
    private init(){
        cacheImages.totalCostLimit = 524288000 // 500 MB
    }
    
    func searchImage(urlString: String) -> UIImage? {
        // 메모리 캐시
        let nsString = NSString(string: urlString)
        if let image = cacheImages.object(forKey: nsString) {
            return image
        }

        // 디스크 캐시
        guard let imageFilePathURL = imageFilePathURL(urlString: urlString) else { return nil }
        
        if fileManager.fileExists(atPath: imageFilePathURL.path) {
            guard let imageData = try? Data(contentsOf: imageFilePathURL) else { return nil }
            guard let image = UIImage(data: imageData) else { return nil }
            print(Date().timeIntervalSince1970)
            cacheImages.setObject(image, forKey: nsString)
            return image
        }
        return nil
    }
    
    func cacheImage(urlString: String, image: UIImage) {
        // 메모리 캐시
        let nsString = NSString(string: urlString)
        cacheImages.setObject(image, forKey: nsString)
        
        // 디스크 캐시
        guard let imageFilePathURL = imageFilePathURL(urlString: urlString) else { return }
        
        guard let imageData = image.pngData() else { return }
        let imageNSData = NSData(data: imageData)
        
        imageNSData.write(to: imageFilePathURL, atomically: true)
    }
    
    private func imageFilePathURL(urlString: String) -> URL? {
        guard let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first else { return nil}
        var filePathURL = URL(fileURLWithPath: path)
        
        guard let imageServerURL = URL(string: urlString) else { return nil }
        let imageName = imageServerURL.lastPathComponent
        filePathURL.appendPathComponent(imageName)
        
        return filePathURL
    }
}
