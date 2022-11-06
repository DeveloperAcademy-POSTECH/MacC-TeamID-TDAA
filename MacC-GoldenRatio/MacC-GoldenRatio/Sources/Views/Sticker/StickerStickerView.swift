//
//  StickerStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import RxCocoa
import RxSwift
import UIKit

class StickerStickerView: StickerView {
    private let stickerImageView: UIImageView = {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: UIScreen.getDevice().stickerDefaultSize))
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()

    /// StickerView를 새로 만듭니다.
    init(sticker: String, appearPoint: CGPoint) {
        super.init(frame: stickerImageView.frame)

        Task{
            self.stickerViewData = await StickerViewData(itemType: .sticker, contents: [sticker], appearPoint: appearPoint, defaultSize: stickerImageView.frame.size, lastEditor: UserManager.shared.userUID)
            await self.configureStickerViewData()
            await self.setStickerImage()

            DispatchQueue.main.async {
                super.setupContentView(content: self.stickerImageView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task{
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.setStickerImage()

            DispatchQueue.main.async {
                super.setupContentView(content: self.stickerImageView)
                super.setupDefaultAttributes()
                self.subviews.forEach{
                    $0.isUserInteractionEnabled = true
                }
            }
        }
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setStickerImage() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .map {
                guard let imageName = $0.first else { return "" }
                return imageName
            }
            .subscribe(onNext: {
                self.stickerImageView.image = UIImage(named: $0)
            })
            .disposed(by: self.disposeBag)
        
    }
}
