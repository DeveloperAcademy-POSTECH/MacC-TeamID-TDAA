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
    init(image: UIImage, diaryUUID: String) {
        super.init(frame: imageView.frame)

        upLoadImage(image: image, path: "Diary/" + diaryUUID.description)
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
            self.configureImageView()
            super.setupContentView(content: self.imageView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() {
        guard let imageUrl = super.stickerViewData.item.contents.first else { return }
        
        let image = ImageManager.shared.searchImage(url: imageUrl)
        
        switch image {
        case nil:
            downLoadImage(imageUrl: imageUrl)
            return
        default:
            self.imageView.image = image
            return
        }
    }
    
    private func downLoadImage(imageUrl: String) {
        FirebaseStorageManager.downloadImage(urlString: imageUrl) { image in
            guard let image = image else { return }
            ImageManager.shared.cacheImage(url: imageUrl, image: image)
            self.imageView.image = image
        }
    }
    
    private func upLoadImage(image: UIImage, path: String) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: path) { url in
            self.imageView.image = image
            guard let url = url else { return }
            ImageManager.shared.cacheImage(url: url.absoluteString, image: image)
            self.stickerViewData.updateContents(contents: [url.absoluteString])
        }
    }

}
