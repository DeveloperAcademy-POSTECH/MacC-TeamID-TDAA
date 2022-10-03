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
}
