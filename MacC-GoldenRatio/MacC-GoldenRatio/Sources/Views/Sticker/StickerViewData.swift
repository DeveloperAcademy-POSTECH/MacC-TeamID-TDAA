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
    
    func fetchFrame() -> CGRect {
        let x = item.itemFrame[0]
        let y = item.itemFrame[1]
        let width = item.itemFrame[2]
        let height = item.itemFrame[3]

        return CGRect(x: x, y: y, width: width, height: height)
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
    
    func updateContents(contents: [String]) {
        self.item.contents = contents
    }
    
    func updateItem(sticker: StickerView) async {
        let itemFrame: [Double] = await [sticker.frame.minX, sticker.frame.minY, sticker.frame.size.width, sticker.frame.size.height]
        let itemBounds: [Double] = await [sticker.bounds.minX, sticker.bounds.minY, sticker.bounds.size.width, sticker.bounds.size.height]
        let itemTrasnform: [Double] = await [sticker.transform.a, sticker.transform.b, sticker.transform.c, sticker.transform.d, sticker.transform.tx, sticker.transform.ty]
        let itemContents: [String] = await sticker.stickerViewData.item.contents
        
        item.itemFrame = itemFrame
        item.itemBounds = itemBounds
        item.itemTransform = itemTrasnform
        item.contents = itemContents
    }
}
