//
//  TabBarController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit

class TabBarController: UITabBarController {
	private lazy var myDiariesViewController: UIViewController = {
		let viewController = MyHomeViewController()
		
		let pressImage = UIImage(named: "pressHome")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressHome")?.withRenderingMode(.alwaysOriginal)
		
		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myPlacesViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyPlaceViewController())
		viewController.isNavigationBarHidden = true
		let pressImage = UIImage(named: "pressMap")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressMap")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myAlbumsViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyAlbumViewController())
		
		let pressImage = UIImage(named: "pressAlbum")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressAlbum")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myPageViewController: UIViewController = {
        let viewController = MyPageViewController()
		let pressImage = UIImage(named: "pressProfile")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressProfile")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
		self.tabBar.tintColor = UIColor.clear
        UITabBar.appearance().barTintColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
		self.tabBar.unselectedItemTintColor = UIColor.clear
		viewControllers = [myDiariesViewController, myPlacesViewController, myAlbumsViewController, myPageViewController]
	}

}
