//
//  StickerBorderView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import UIKit

/// StickerView의 테두리를 나타내는 사각형 뷰
class StickerBorderView: UIView {
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        guard let context = context else { return }
        context.saveGState()
        context.setLineWidth(1)
        let dash: [CGFloat] = [1.0, 0.0]
        context.setLineDash(phase: 0.0, lengths: dash)
        context.setStrokeColor(UIColor.black.cgColor)
        context.addRect(rect)
        context.strokePath()
        context.restoreGState()
    }

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
    }

}
