//
//  TextStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class TextStickerView: StickerView {
    
    let textView: UITextView = {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 27.3, height: 40)))
        textView.backgroundColor = .clear
        textView.font = .navigationTitleFont
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        
        return textView
    }()
    
    /// StickerView를 새로 만듭니다.
    init(appearPoint: CGPoint) {
        super.init(frame: textView.frame)
        
        self.configureNewStickerView()

        Task {
            self.stickerViewData = await StickerViewData(itemType: .text, contents: [""], appearPoint: appearPoint, defaultSize: textView.frame.size)
            await self.configureStickerViewData()
            await self.setTextView()
            await self.setTextStickerViewFrame()
            await self.bindIsStickerViewActive()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.setTextView()
            await self.bindIsStickerViewActive()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextView() async {
        
        self.textView.delegate = self
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .map { $0[0] }
            .bind(to: self.textView.rx.text)
            .disposed(by: self.disposeBag)
        
    }
    
    private func setTextStickerViewFrame() async {
        DispatchQueue.main.async {
            self.frame.origin.x -= ( self.textView.frame.width / 2 - 50 )
            self.frame.origin.y -= ( self.textView.frame.height / 2 - 50 )
        }
    }
    
    private func bindIsStickerViewActive() async {
        self.isStickerViewActive
            .subscribe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.textView.isEditable = $0
                self.textView.isUserInteractionEnabled = $0
                
                if !$0 {
                    self.textView.endEditing(true)
                }
            })
            .disposed(by: disposeBag)
    }
    
}

extension TextStickerView {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.becomeFirstResponder()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.resignFirstResponder()
        super.touchesMoved(touches, with: event)
    }
    
}

extension TextStickerView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        print("begineding")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        Task {
            await stickerViewData?.updateItem(sticker: self, contents: [textView.text], lastEditor: nil)
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            let size = CGSize(width: 2000, height: 2000)
            let estimatedSize = textView.sizeThatFits(size)
            self.textView.frame = CGRect(origin: textView.frame.origin, size: estimatedSize)
            self.bounds = self.textView.frame
            self.updateControlsPosition()
        }
    }
    
}
