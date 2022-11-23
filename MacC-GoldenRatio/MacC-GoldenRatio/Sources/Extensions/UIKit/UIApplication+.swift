//
//  UIApplication+.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/22.
//

import UIKit

extension UIApplication {
    
    // 현재의 ViewController를 얻는 UIApplication Extension
    class func currentViewController(base: UIViewController? = UIApplication.shared.windows.first(where: \.isKeyWindow)?.rootViewController) -> UIViewController? {
        if let navigation = base as? UINavigationController {
            return currentViewController(base: navigation.visibleViewController)
        }

        if let presented = base?.presentedViewController {
            return currentViewController(base: presented)
        }
        return base
    }
}
