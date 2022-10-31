//
//  StickerViewData.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/06.
//

import RxSwift
import UIKit

class StickerViewData {
    
    private var disposeBag = DisposeBag()
    
    var itemObservable: BehaviorSubject<Item>!
    
    var frameObservable: Observable<CGRect>!
    
    var boundsObservable: Observable<CGRect>!
    
    var transitionObservable: Observable<CGAffineTransform>!
    
    var contentsObservable: Observable<[String]>!
    
    init(itemType: ItemType) async {
        
        let id = UUID().uuidString + String(Date().timeIntervalSince1970)
        let item = Item(itemUUID: id, itemType: itemType, contents: [], itemFrame: [0.0, 0.0, 100.0, 100.0], itemBounds: [0.0, 0.0, 100.0, 100.0], itemTransform: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0])
        self.itemObservable = BehaviorSubject(value: item)
        self.frameObservable = await self.createFrameObservable()
        self.boundsObservable = await self.createBoundsObservable()
        self.transitionObservable = await self.createTransformObservable()
        self.contentsObservable = await self.createContentsObservable()
        
    }
    
    init(item: Item) async {
        self.itemObservable = BehaviorSubject(value: item)
        self.frameObservable = await self.createFrameObservable()
        self.boundsObservable = await self.createBoundsObservable()
        self.transitionObservable = await self.createTransformObservable()
        self.contentsObservable = await self.createContentsObservable()
    }
    
    private func createFrameObservable() async -> Observable<CGRect> {
        itemObservable.map { item in
            return item.fetchFrame()
        }
    }
    
    private func createBoundsObservable() async -> Observable<CGRect> {
        itemObservable.map { item in
            return item.fetchBounds()
        }
    }
    
    private func createTransformObservable() async -> Observable<CGAffineTransform> {
        itemObservable.map { item in
            return item.fetchTransform()
        }
    }
    
    private func createContentsObservable() async -> Observable<[String]> {
        itemObservable.map { item in
            return item.fetchContents()
        }
    }
    
    func updateContents(contents: [String]) async {
        
        self.itemObservable.map { item in
            var newItem = item
            newItem.contents = contents
            
            return newItem
        }
        .subscribe(onNext: {
            self.itemObservable.onNext($0)
        })
        .disposed(by: disposeBag)
        
    }
    
    // TODO: 이름 바꾸기 ( contents 는 업데이트 하지 않음 )
    func updateItem(sticker: StickerView) {
        let itemFrame: [Double] = [sticker.frame.minX, sticker.frame.minY, sticker.frame.size.width, sticker.frame.size.height]
        let itemBounds: [Double] = [sticker.bounds.minX, sticker.bounds.minY, sticker.bounds.size.width, sticker.bounds.size.height]
        let itemTrasnform: [Double] = [sticker.transform.a, sticker.transform.b, sticker.transform.c, sticker.transform.d, sticker.transform.tx, sticker.transform.ty]

        self.itemObservable.map { item in
            var newItem = item
            newItem.itemFrame = itemFrame
            newItem.itemBounds = itemBounds
            newItem.itemTransform = itemTrasnform
            
            return newItem
        }
        .subscribe(onNext: {
            self.itemObservable.onNext($0)
        })
        .disposed(by: disposeBag)
    }
    
}
