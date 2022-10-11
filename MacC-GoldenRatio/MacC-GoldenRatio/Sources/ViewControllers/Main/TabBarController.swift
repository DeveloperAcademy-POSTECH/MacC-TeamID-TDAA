//
//  TabBarController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit

class TabBarController: UITabBarController {
	private lazy var myDiariesViewController: UIViewController = {
		let viewController = MyDiariesViewController()
		
		let pressImage = UIImage(named: "pressHome")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressHome")?.withRenderingMode(.alwaysOriginal)
		
		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myPlacesViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyPlacesViewController())
		
		let pressImage = UIImage(named: "pressMap")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressMap")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myAlbumsViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyAlbumsViewController())
		
		let pressImage = UIImage(named: "pressAlbum")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressAlbum")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	private lazy var myPageViewController: UIViewController = {
        let viewController = UINavigationController(rootViewController: PageViewController())

		let pressImage = UIImage(named: "pressProfile")?.withRenderingMode(.alwaysOriginal)
		let notPressImage = UIImage(named: "notPressProfile")?.withRenderingMode(.alwaysOriginal)

		viewController.tabBarItem.image = notPressImage
		viewController.tabBarItem.selectedImage = pressImage
		
		return viewController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = .systemBackground
		self.tabBar.tintColor = UIColor.clear
		self.tabBar.unselectedItemTintColor = UIColor.clear
		viewControllers = [myDiariesViewController, myPlacesViewController, myAlbumsViewController, myPageViewController]
	}

}
