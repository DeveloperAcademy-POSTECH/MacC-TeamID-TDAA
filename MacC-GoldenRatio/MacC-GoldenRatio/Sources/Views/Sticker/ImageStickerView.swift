//
//  ImageStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import UIKit

class ImageStickerView: StickerView {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: UIScreen.getDevice().stickerDefaultSize))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// StickerView를 새로 만듭니다.
    init(image: UIImage) {
        super.init(frame: imageView.frame)

        upLoadImage(image: image)
        DispatchQueue.main.async {
            self.initializeStickerViewData(itemType: .image)
            super.setupContentView(content: self.imageView)
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        DispatchQueue.main.async{
            self.stickerViewData = StickerViewData(item: item)
            self.configureStickerViewData()
            self.downLoadImage()
            super.setupContentView(content: self.imageView)
            super.setupDefaultAttributes()
        }
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func downLoadImage() {
        guard let imageURL = super.stickerViewData.item.contents.first else { return }
        FirebaseStorageManager.downloadImage(urlString: imageURL) { image in
            self.imageView.image = image
        }
    }
    
    private func upLoadImage(image: UIImage) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: "") { url in
            self.imageView.image = image
            guard let url = url else {return}
            self.stickerViewData.updateContents(contents: [url.absoluteString])
        }
    }

}
