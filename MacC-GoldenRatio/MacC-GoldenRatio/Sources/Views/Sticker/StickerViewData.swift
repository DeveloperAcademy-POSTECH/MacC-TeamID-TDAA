//
//  StickerViewData.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/06.
//

import UIKit

class StickerViewData {
    var item: Item
    
    init(item: Item) {
        self.item = item
    }
    
    func fetchBounds() -> CGRect {
        let x = item.itemBounds[0]
        let y = item.itemBounds[1]
        let width = item.itemBounds[2]
        let height = item.itemBounds[3]

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func fetchTransform() -> CGAffineTransform {
        let a = item.itemTransform[0]
        let b = item.itemTransform[1]
        let c = item.itemTransform[2]
        let d = item.itemTransform[3]
        let tx = item.itemTransform[4]
        let ty = item.itemTransform[5]

        return CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
    func fetchContent() {
        
    }
    
    func updateItem(sticker: StickerView) async {
        let itemBounds: [Double] = await [sticker.frame.origin.x, sticker.frame.origin.y, sticker.frame.size.width, sticker.frame.size.height]
        let itemTrasnform: [Double] = await [sticker.transform.a, sticker.transform.b, sticker.transform.c, sticker.transform.d, sticker.transform.tx, sticker.transform.ty]
        var itemContents: [String] = []
        
        switch await sticker.stickerViewData.item.itemType {
        case .text:
            let sticker = sticker as! TextStickerView
            itemContents = await [sticker.textView.text]
//        case .image:
//            let sticker = sticker as! ImageStickerView
//            itemContents = sticker
//        case .sticker:
//
//        case .location:

        default: break
        }
        
        item.itemBounds = itemBounds
        item.itemTransform = itemTrasnform
        item.contents = itemContents
    }
}
