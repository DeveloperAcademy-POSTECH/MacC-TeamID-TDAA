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
    init(sticker: String) {
        super.init(frame: stickerImageView.frame)

        Task{
            self.stickerViewData = await StickerViewData(itemType: .sticker)
            await self.configureStickerViewData()
            await self.stickerViewData?.updateContents(contents: [sticker])
            await self.setStickerImage()
            super.setupContentView(content: self.stickerImageView)
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task{
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.setStickerImage()
            super.setupContentView(content: self.stickerImageView)
            super.setupDefaultAttributes()
        }
       
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setStickerImage() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.asyncInstance)
            .map { $0[0] }
            .subscribe(onNext: {
                self.stickerImageView.image = UIImage(named: $0)
            })
            .disposed(by: self.disposeBag)
        
    }
}
