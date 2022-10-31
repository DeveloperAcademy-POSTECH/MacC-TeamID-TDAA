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
    override var subviewIsHidden: Bool {
        willSet {
            self.textView.isEditable = !newValue
            self.textView.isUserInteractionEnabled = !newValue
        }
    }
    
    let textView: UITextView = {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 27.3, height: 40)))
        textView.backgroundColor = .clear
        textView.font = .navigationTitleFont
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        
        return textView
    }()
    
    /// StickerView를 새로 만듭니다.
    init() {
        super.init(frame: textView.frame)
        
        Task {
            self.stickerViewData = await StickerViewData(itemType: .text)
            await self.configureStickerViewData()
            await self.setTextView()
            super.setupContentView(content: textView)
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.setTextView()
            super.setupContentView(content: self.textView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextView() async {
        
        self.textView.delegate = self
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.asyncInstance)
            .map { $0[0] }
            .bind(to: self.textView.rx.text)
            .disposed(by: self.disposeBag)
        
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
    
    func textViewDidChange(_ textView: UITextView) {
        Task {
            await stickerViewData?.updateContents(contents: [self.textView.text])

            let size = CGSize(width: 2000, height: 2000)
            let estimatedSize = textView.sizeThatFits(size)

            DispatchQueue.main.async {
                self.textView.frame = CGRect(origin: textView.frame.origin, size: estimatedSize)
                self.bounds = self.textView.frame
                self.updateControlsPosition()
            }
        }
    }
    
}
