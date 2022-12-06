//
//  UIColor+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/13.
//

import UIKit

extension UIColor {
	
    // MARK: Basic Colors
    static var beige100: UIColor {
        let color = UIColor(named: "beige100") ?? .blue
        return color
    }
    
    static var beige200: UIColor {
        let color = UIColor(named: "beige200") ?? .blue
        return color
    }
    
    static var beige300: UIColor {
        let color = UIColor(named: "beige300") ?? .blue
        return color
    }
    
    static var beige400: UIColor {
        let color = UIColor(named: "beige400") ?? .blue
        return color
    }
    
    static var beige500: UIColor {
        let color = UIColor(named: "beige500") ?? .blue
        return color
    }
    
    static var beige600: UIColor {
        let color = UIColor(named: "beige600") ?? .blue
        return color
    }
    
    static var gray100: UIColor {
        let color = UIColor(named: "gray100") ?? .gray
        return color
    }
    
    static var gray200: UIColor {
        let color = UIColor(named: "gray200") ?? .gray
        return color
    }
    
    static var gray300: UIColor {
        let color = UIColor(named: "gray300") ?? .gray
        return color
    }
    
    static var gray400: UIColor {
        let color = UIColor(named: "gray400") ?? .gray
        return color
    }
    
    static var gray500: UIColor {
        let color = UIColor(named: "gray500") ?? .gray
        return color
    }
    
    static var essential: UIColor {
        let color = UIColor(named: "essential") ?? .red
        return color
    }
    
    
    // MARK: Texture
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
    
    
    // MARK: Gradient Color Method
    static func gradientColor(alpha: CGFloat) -> UIColor {
        let color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: alpha)
        return color
    }
}
