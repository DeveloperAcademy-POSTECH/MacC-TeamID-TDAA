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
        
    init(itemType: ItemType, contents: [String], appearPoint: CGPoint, defaultSize: CGSize, lastEditor: String?) async {
        
        let id = UUID().uuidString + String(Date().timeIntervalSince1970)
        let item = Item(itemUUID: id, itemType: itemType, contents: contents, itemFrame: [appearPoint.x, appearPoint.y, defaultSize.width, defaultSize.height], itemBounds: [0.0, 0.0, defaultSize.width, defaultSize.height], itemTransform: [1.0, 0.0, 0.0, 1.0, 0.0, 0.0])
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
    
    func updateItem(sticker: StickerView, contents: [String], lastEditor: String?) async {
        let itemFrame: [Double] = await [sticker.frame.origin.x, sticker.frame.origin.y, sticker.frame.size.width, sticker.frame.size.height]
        let itemBounds: [Double] = await [sticker.bounds.origin.x, sticker.bounds.origin.y, sticker.bounds.size.width, sticker.bounds.size.height]
        let itemTrasnform: [Double] = await [sticker.transform.a, sticker.transform.b, sticker.transform.c, sticker.transform.d, sticker.transform.tx, sticker.transform.ty]
        
        self.itemObservable
            .observe(on: MainScheduler.instance)
            .map { item in
                var newItem = item
                newItem.itemFrame = itemFrame
                newItem.itemBounds = itemBounds
                newItem.itemTransform = itemTrasnform
                newItem.contents = contents
                
                return newItem
            }
            .take(1)
            .subscribe(onNext: {
                self.itemObservable.onNext($0)
            })
            .disposed(by: disposeBag)
    }
    
    func updateContents(contents: [String]) async {
        
        self.itemObservable
            .observe(on: MainScheduler.instance)
            .map { item in
                var newItem = item
                newItem.contents = contents
                
                return newItem
            }
            .take(1)
            .subscribe(onNext: {
                self.itemObservable.onNext($0)
            })
            .disposed(by: disposeBag)
        
    }
    
    func updateUIItem(frame: CGRect, bounds: CGRect, transform: CGAffineTransform) async {
        let itemFrame: [Double] = [frame.origin.x, frame.origin.y, frame.size.width, frame.size.height]
        let itemBounds: [Double] = [0, 0, bounds.size.width, bounds.size.height]
        let itemTrasnform: [Double] = [transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty]

        self.itemObservable
            .observe(on: MainScheduler.instance)
            .map { item in
                var newItem = item
                newItem.itemFrame = itemFrame
                newItem.itemBounds = itemBounds
                newItem.itemTransform = itemTrasnform
                
                return newItem
            }
            .take(1)
            .subscribe(onNext: {
                self.itemObservable.onNext($0)
            })
            .disposed(by: disposeBag)
    }
}
