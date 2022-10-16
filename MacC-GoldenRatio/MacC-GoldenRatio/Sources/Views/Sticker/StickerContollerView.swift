//
//  StickerContollerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import UIKit


/// 스티커에 붙어있는 버튼  ex) 이동, 삭제 버튼
class StickerControllerView: UIImageView {
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    
    init(image: UIImage?, gestureRecognizer: UIGestureRecognizer) {
        super.init(image: image)

        tintColor = .buttonColor
        addGestureRecognizer(gestureRecognizer)
        frame = CGRect(origin: .zero, size: myDevice.stickerControllerSize)

        layer.cornerRadius = frame.width / 2
        isUserInteractionEnabled = true
        contentMode = .scaleAspectFit
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
