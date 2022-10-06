//
//  TextStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

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
        textView.font = .systemFont(ofSize: 20)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        
        return textView
    }()
    
    /// StickerView를 새로 만듭니다.
    init() {
        super.init(frame: textView.frame)
        
        self.textView.delegate = self
        self.initializeStickerViewData()
        super.setupContentView(content: textView)
        super.setupDefaultAttributes()
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        DispatchQueue.main.async{
            self.textView.delegate = self
            self.configureStickerViewData(item: item)
            super.setupContentView(content: self.textView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initializeStickerViewData() {
        let id = UUID().uuidString
        let item = Item(itemUUID: id, itemType: .text, contents: [], itemBounds: [], itemTransform: [])
        self.stickerViewData = StickerViewData(item: item)
    }
    
    /// StickerViewData 를 현재 View의 프로퍼티들에게 적용합니다.
    private func configureStickerViewData(item: Item) {
        super.stickerViewData = StickerViewData(item: item)
        self.textView.text = item.contents.first

        self.bounds = self.stickerViewData.fetchBounds()
        self.transform = self.stickerViewData.fetchTransform()
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
        let size = CGSize(width: 2000, height: 2000)
        let estimatedSize = textView.sizeThatFits(size)

        textView.frame = CGRect(origin: textView.frame.origin, size: estimatedSize)
        bounds = textView.frame
        updateControlsPosition()
    }
    
}
