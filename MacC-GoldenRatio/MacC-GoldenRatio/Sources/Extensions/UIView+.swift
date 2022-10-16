//
//  UIImage+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/03.
//

import UIKit

extension UIView {
    func transformToImage() -> UIImage? {
        /*
        테스트 중인 코드입니다.
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        */
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    func convertViewToImageView() -> UIImageView {
        let image = self.transformToImage()
        let imageView = UIImageView(image: image)
        imageView.frame = self.frame
        return imageView
    }
    func setUnderLine(width: CGFloat) {
        let view = UIView()
        view.backgroundColor = .buttonColor
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(width)
        }
    }
}
