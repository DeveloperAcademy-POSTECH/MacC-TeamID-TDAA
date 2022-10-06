//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import Foundation

class PageViewModel {
    var stickerArray: [StickerView] = []
    
    init() {
        let item = Item(itemUUID: UUID().uuidString, itemType: .text, contents: ["화려한 불빛으로\n 그 뒷 모습만 보이며 \n안녕이란 말도 없이 사라진 그대"], itemBounds: [28,55,220,320], itemTransform: [0.75815426405639663, 0.6520752348411214, -0.6520752348411214, 0.75815426405639663, 0, 0])
        appendSticker(TextStickerView(item: item))
    }
    
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
