//
//  TabBarController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import UIKit

class TabBarController: UITabBarController {
	
	init() {
		super.init(nibName: nil, bundle: nil)
		object_setClass(self.tabBar, WeiTabBar.self)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	// 출처: https://gist.github.com/calt/7ea29a65b440c2aa8a1a
	class WeiTabBar: UITabBar {
		override func sizeThatFits(_ size: CGSize) -> CGSize {
			var sizeThatFits = super.sizeThatFits(size)
			sizeThatFits.height = 100
			return sizeThatFits
		}
	}
	
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
	
	private lazy var createDiaryViewController: UIViewController = {
		let viewController = UIViewController()
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "plus"), tag: 2)
		
		viewController.modalTransitionStyle = UIModalTransitionStyle.coverVertical
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	private lazy var myAlbumsViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyAlbumsViewController())
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "photo"), tag: 3)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	private lazy var myPageViewController: UIViewController = {
		let viewController = UINavigationController(rootViewController: MyPageViewController())
		
		let tabBarItem = UITabBarItem(title: "", image: UIImage(systemName: "person"), tag: 4)
		
		viewController.tabBarItem = tabBarItem
		
		return viewController
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.delegate = self
		
		view.backgroundColor = .systemBackground
		
		viewControllers = [myDiariesViewController, myPlacesViewController, createDiaryViewController, myAlbumsViewController, myPageViewController]
	}
	
	func showCreateDiaryAlert() {
		let alert = UIAlertController(title: "", message: "", preferredStyle: .actionSheet)
		let createDiaryAction = UIAlertAction(title: "다이어리 만들기", style: .default) { action in
			print("a")
		}
		let joinDiaryAction = UIAlertAction(title: "초대코드로 입장하기", style: .default) { action in
			self.showJoinDiaryAlert()
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		alert.addAction(createDiaryAction)
		alert.addAction(joinDiaryAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}
	
	func showJoinDiaryAlert() {
		let joinDiaryAlert = UIAlertController(title: "초대코드 입력", message: "", preferredStyle: .alert)
		let joinAction = UIAlertAction(title: "확인", style: .default) { action in
			if let textField = joinDiaryAlert.textFields?.first {
				print(textField.text)
			}
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		joinDiaryAlert.addTextField()
		joinDiaryAlert.addAction(joinAction)
		joinDiaryAlert.addAction(cancelAction)
		self.present(joinDiaryAlert, animated: true)
	}

}

// 출처:https://www.hackingwithswift.com/example-code/uikit/how-do-you-show-a-modal-view-controller-when-a-uitabbarcontroller-tab-is-tapped
extension TabBarController: UITabBarControllerDelegate {
	func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
		
		if viewController.tabBarItem.tag == 2 {
			showCreateDiaryAlert()
			return false
		}
		
		return true
	}
}
