//
//  StickerContollerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import UIKit


/// 스티커에 붙어있는 버튼  ex) 이동, 삭제 버튼
class StickerControllerView: UIImageView {
    private let controlSize = CGSize(width: 22, height: 22)
    
    init(image: UIImage?, gestureRecognizer: UIGestureRecognizer) {
        super.init(image: image)

        self.tintColor = .black
        self.addGestureRecognizer(gestureRecognizer)
        self.frame = CGRect(origin: .zero, size: controlSize)

        layer.cornerRadius = frame.width / 2
        isUserInteractionEnabled = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
