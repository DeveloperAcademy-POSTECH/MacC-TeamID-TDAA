//
//  StickerStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import UIKit

class StickerStickerView: StickerView {
    private var sticker: String?

    init(sticker: String, size: CGSize) {
        self.sticker = sticker
        let image = UIImage(named: sticker)
        let stickerImageView = UIImageView(image: image)
        stickerImageView.contentMode = .scaleAspectFit
        stickerImageView.frame = CGRect(origin: .zero, size: size)
        super.init(frame: stickerImageView.frame)

        DispatchQueue.main.async {
            super.setupContentView(content: stickerImageView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
