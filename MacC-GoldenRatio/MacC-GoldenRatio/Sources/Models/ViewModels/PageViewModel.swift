//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import Foundation

class PageViewModel {
    var stickerArray: [StickerView] = []
    
    func appendSticker(_ sticker: StickerView) {
        stickerArray.append(sticker)
        debugPrint(stickerArray)

    }
    
    func removeSticker(_ sticker: StickerView) {
        guard let index = stickerArray.firstIndex(of: sticker) else { return }
        stickerArray.remove(at: index)
        debugPrint(stickerArray)

    }
    
    func hideStickerSubviews() {
        stickerArray.forEach{
            $0.subviewIsHidden = true
        }
        debugPrint(stickerArray)

    }
    
    func bringStickerToFront(_ sticker: StickerView) {
        guard let index = stickerArray.firstIndex(of: sticker) else { return }
        stickerArray.remove(at: index)
        stickerArray.append(sticker)
        debugPrint(stickerArray)
    }
}
