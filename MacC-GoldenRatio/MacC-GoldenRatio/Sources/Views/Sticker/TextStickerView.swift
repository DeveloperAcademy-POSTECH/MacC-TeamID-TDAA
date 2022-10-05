//
//  TextStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import UIKit

class TextStickerView: StickerView {
    private var textView: UITextView!
    
    override var subviewIsHidden: Bool {
        willSet {
            self.textView.isEditable = !newValue
            self.textView.isUserInteractionEnabled = !newValue
        }
    }
    
    init() {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 27.3, height: 40)))
        textView.backgroundColor = .clear
        textView.text = ""
        textView.font = .systemFont(ofSize: 20)
        textView.isScrollEnabled = false
        textView.isUserInteractionEnabled = false
        
        super.init(frame: textView.frame, content: textView)
        self.textView = textView
        self.textView.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
