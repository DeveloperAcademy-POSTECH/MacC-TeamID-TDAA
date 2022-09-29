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
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "house"), tag: 0)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	private lazy var myPlacesViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyPlacesViewController())
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "map"), tag: 1)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	private lazy var myAlbumsViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyAlbumsViewController())
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "photo"), tag: 1)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	private lazy var myPageViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyPageViewController())
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 1)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
	   
		viewControllers = [myDiariesViewController, myPlacesViewController, myAlbumsViewController, myPageViewController]
	}


}
