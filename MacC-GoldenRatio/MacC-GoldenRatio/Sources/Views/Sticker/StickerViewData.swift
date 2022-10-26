//
//  StickerViewData.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/06.
//

import UIKit
import FirebaseAuth

class StickerViewData {
    var item: Item
    
    init(item: Item) {
        if item.checkItemValidate() {
            self.item = item
        } else {
            let itemUUID = UUID().uuidString + Date().timeIntervalSince1970.description
            let item = Item(itemUUID: itemUUID, itemType: .sticker, contents: ["redAlert"], itemFrame: [0.0, 0.0, 100.0, 100.0], itemBounds: [0.0, 0.0, 100.0, 100.0], itemTransform: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0])
            self.item = item
        }
    }
    
    func fetchCurrentEditor() -> String? {
        return item.lastEditor
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
    
    func updateItem(sticker: StickerView) -> Bool {
        let oldItem = item
        
        let itemFrame: [Double] = [sticker.frame.minX, sticker.frame.minY, sticker.frame.size.width, sticker.frame.size.height]
        let itemBounds: [Double] = [sticker.bounds.minX, sticker.bounds.minY, sticker.bounds.size.width, sticker.bounds.size.height]
        let itemTrasnform: [Double] = [sticker.transform.a, sticker.transform.b, sticker.transform.c, sticker.transform.d, sticker.transform.tx, sticker.transform.ty]
        let itemContents: [String] = sticker.stickerViewData.item.contents
        let userUUID: String = Auth.auth().currentUser?.uid ?? ""

        item.itemFrame = itemFrame
        item.itemBounds = itemBounds
        item.itemTransform = itemTrasnform
        item.contents = itemContents
        let isEditing = !sticker.isSubviewHidden
        if isEditing {
            if item.lastEditor == nil {
                item.lastEditor = userUUID
            }
        } else {
            item.lastEditor = nil
        }
        
        return item != oldItem
    }
}
