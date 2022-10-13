//
//  StickerStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

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

        DispatchQueue.main.async {
            self.initializeStickerViewData(itemType: .sticker)
            self.stickerViewData.item.contents = [sticker]
            self.setStickerImage()
            super.setupContentView(content: self.stickerImageView)
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item, isSubviewHidden: Bool) {
        super.init(frame: CGRect())

        DispatchQueue.main.async{
            self.stickerViewData = StickerViewData(item: item)
            self.configureStickerViewData()
            self.setStickerImage()
            super.setupContentView(content: self.stickerImageView)
            super.setupDefaultAttributes()
            self.subviewIsHidden = isSubviewHidden
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setStickerImage() {
        guard let stickerString = super.stickerViewData.item.contents.first else { return }
        stickerImageView.image = UIImage(named: stickerString)
    }
}
