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
            
            DispatchQueue.global(qos: .utility).async { [weak self] in
                let imageSize = imageData.count
                self?.cacheImages.setObject(image, forKey: nsString, cost: imageSize)
            }

            return image
        }
        return nil
    }
    
    func cacheImage(urlString: String, image: UIImage) {
        DispatchQueue.global(qos: .utility).async { [weak self] in
            // 이미지 압축
            guard let compressedImageData = image.jpegData(compressionQuality: 0.4) else { return }
            guard let compressedImage = UIImage(data: compressedImageData) else { return }
            
            // 메모리 캐시
            let compressedImageSize = compressedImageData.count
            let nsString = NSString(string: urlString)
            self?.cacheImages.setObject(compressedImage, forKey: nsString, cost: compressedImageSize)
            
            // 디스크 캐시
            guard let imageFilePathURL = self?.imageFilePathURL(urlString: urlString) else { return }
            let imageNSData = NSData(data: compressedImageData)
            imageNSData.write(to: imageFilePathURL, atomically: true)
        }
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
