//
//  ImageStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//
import RxCocoa
import RxSwift
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

        self.upLoadImage(image: image, path: "Diary/" + diaryUUID.description)
        
        Task {
            self.stickerViewData = await StickerViewData(itemType: .image)
            await self.configureStickerViewData()
            super.setupContentView(content: self.imageView)
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.configureImageView()
            super.setupContentView(content: self.imageView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureImageView() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                guard let imageUrl = $0.first else { return }
                let image = ImageManager.shared.searchImage(urlString: imageUrl)
                
                switch image {
                case nil:
                    self.downLoadImage(imageUrl: imageUrl)
                    return
                default:
                    self.imageView.image = image
                    return
                }
            })
            .disposed(by: self.disposeBag)
    
    }
    
    private func downLoadImage(imageUrl: String) {
        FirebaseStorageManager.downloadImage(urlString: imageUrl) { image in
            guard let image = image else { return }
            ImageManager.shared.cacheImage(urlString: imageUrl, image: image)
            self.imageView.image = image
        }
    }
    
    private func upLoadImage(image: UIImage, path: String) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: path) { url in
            self.imageView.image = image
            guard let url = url else { return }
            ImageManager.shared.cacheImage(urlString: url.absoluteString, image: image)
            Task {
                await self.stickerViewData?.updateContents(contents: [url.absoluteString])
            }
        }
    }

}
