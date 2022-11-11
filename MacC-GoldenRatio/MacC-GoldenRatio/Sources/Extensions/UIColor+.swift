//
//  UIColor+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/13.
//

import UIKit

extension UIColor {
    static var navigationbarColor: UIColor {
        let color = UIColor(named: "sandbrownColor")!
        return color
    }
    
    static var buttonColor: UIColor {
        let color = UIColor(named: "darkgrayColor")!
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
    
    static var startDateColor: UIColor {
        let color = UIColor(named: "startDateColor")!
        return color
    }
    
    static var endDateColor: UIColor {
        let color = UIColor(named: "sandbrownColor")!
        return color
    }
    
    static var sandbrownColor: UIColor {
        let color = UIColor(named: "sandbrownColor")!
        return color
    }
    
    static var darkgrayColor: UIColor {
        let color = UIColor(named: "darkgrayColor")!
        return color
    }
    
    static var subTextColor: UIColor {
        let color = UIColor(named: "calendarSubTextColor")!
        return color
    }
    
    static var middleGrayColor: UIColor {
        let color = UIColor(named: "calendarWeeklyGrayColor")!
        return color
    }

    static var calendarWeeklyGrayColor: UIColor {
        let color = UIColor(named: "calendarWeeklyGrayColor")!
        return color
    }
    
    static var separatorColor2: UIColor {
        let color = UIColor(named: "separatorColor2")!
        return color
    }
    
    static func gradientColor(alpha: CGFloat) -> UIColor {
        let color = UIColor(red: 0.2, green: 0.2, blue: 0.2, alpha: alpha)
        return color
    }
  
    static var requiredItemsColor: UIColor {
        let color = UIColor(named: "requiredItemsColor")!
        return color
    }
}
