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
        
        self.initializeStickerViewData(itemType: .text)
        self.setTextView()
        super.setupContentView(content: textView)
        super.setupDefaultAttributes()
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        DispatchQueue.main.async{
            self.stickerViewData = StickerViewData(item: item)
            self.configureStickerViewData()
            self.setTextView()
            super.setupContentView(content: self.textView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextView() {
        self.textView.delegate = self
        
        guard let text = self.stickerViewData.item.contents.first else { return }
        self.textView.text = text
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
        stickerViewData.updateContents(contents: [self.textView.text])
        
        let size = CGSize(width: 2000, height: 2000)
        let estimatedSize = textView.sizeThatFits(size)

        textView.frame = CGRect(origin: textView.frame.origin, size: estimatedSize)
        bounds = textView.frame
        updateControlsPosition()
    }
    
}
