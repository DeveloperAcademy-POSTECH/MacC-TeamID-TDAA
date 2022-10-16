//
//  UIColor+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/13.
//

import UIKit

extension UIColor {
    static var navigationbarColor: UIColor {
        let color = UIColor(named: "navigationbarColor")!
        return color
    }
    
    static var buttonColor: UIColor {
        let color = UIColor(named: "buttonColor")!
        return color
    }
    
    static var backgroundTexture: UIColor {
        let image = UIImage(named: "backgroundTexture")!
        let color = UIColor(patternImage: image)
        return color
    }
    
    static var diaryInnerTexture: UIColor {
        let image = UIImage(named: "diaryInnerTexture")!
        let color = UIColor(patternImage: image)
        return color
    }
    
    static var endDateColor: UIColor {
        let color = UIColor(named: "endDateColor")!
        return color
    }
}