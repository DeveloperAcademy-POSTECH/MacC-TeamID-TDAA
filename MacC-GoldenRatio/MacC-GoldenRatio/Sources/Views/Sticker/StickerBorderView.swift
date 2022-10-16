//
//  StickerBorderView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import UIKit

/// StickerView의 테두리를 나타내는 사각형 뷰
class StickerBorderView: UIView {
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.borderWidth = myDevice.stickerBorderWidth
        layer.borderColor = UIColor.buttonColor.cgColor
    }

}
