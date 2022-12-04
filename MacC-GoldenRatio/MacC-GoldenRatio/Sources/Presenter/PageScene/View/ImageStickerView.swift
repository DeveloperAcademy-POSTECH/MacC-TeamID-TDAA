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
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: Layout.stickerDefaultSize))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// StickerView를 새로 만듭니다.
    init(image: UIImage, diaryUUID: String, appearPoint: CGPoint) {
        super.init(frame: imageView.frame)

        self.configureNewStickerView()
        self.upLoadImage(image: image, path: "Diary/" + diaryUUID.description)
        
        Task {
            self.stickerViewData = await StickerViewData(itemType: .image, contents: [""], appearPoint: appearPoint, defaultSize: imageView.frame.size)
            await self.configureStickerViewData()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.imageView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.configureImageView()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.imageView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configureNewStickerView() {
        super.configureNewStickerView()
    }
    
    private func configureImageView() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                guard let imageUrl = $0.first else { return }
                
                guard imageUrl.verifyUrl() else {
                    self.removeFromSuperview()
                    return
                }
                
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
        DispatchQueue.global(qos: .userInitiated).async() {
            FirebaseStorageManager.uploadImage(image: image, pathRoot: path) { url in
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
                
                guard let url = url else { return }
                ImageManager.shared.cacheImage(urlString: url.absoluteString, image: image)
                self.stickerViewData?.updateContents(contents: [url.absoluteString], completion: {
                    DispatchGroup.uploadImageDispatchGroup.leave()
                })
            }
        }
    }

}
