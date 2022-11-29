//
//  SceneDelegate.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import FirebaseDynamicLinks
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UINavigationController(rootViewController: SignInViewController()) // 시작 VC 작성해주기
        window.makeKeyAndVisible()
        self.window = window
        
        // 앱이 Running 상태가 아닐 때 DynamicLink 수신
        if let userActivity = connectionOptions.userActivities.first {
            self.scene(scene, continue: userActivity)
        }
    }
    
    // DynamicLink 수신
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let incomingURL = userActivity.webpageURL {
            DynamicLinks.dynamicLinks().handleUniversalLink(incomingURL) { dynamiclink, error in
                if let urlString = dynamiclink?.url?.absoluteString {
                    guard let currentViewController = UIApplication.currentViewController() else { return }
                    
                    if currentViewController is MyHomeViewController {
                        // 접속한 화면이 HomeViewController인 경우
                        self.addDiaryInHomeViewController(urlString: urlString)
                        
                    } else if currentViewController is SignInViewController {
                        let signInViewController = currentViewController as! SignInViewController
                        // 접속한 화면이 SignInViewController인 경우
                        signInViewController.completion = {
                            self.addDiaryInHomeViewController(urlString: urlString)
                        }
                        
                    } else {
                        // 접속한 화면이 다른 ViewController인 경우
                        for controller in currentViewController.navigationController!.viewControllers as Array {
                            if controller.isKind(of: MyHomeViewController.self) {
                                currentViewController.navigationController!.popToViewController(controller, animated: true)
                                self.addDiaryInHomeViewController(urlString: urlString)
                                break
                            }
                        }
                    }
                }
            }
        }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func addDiaryInHomeViewController(urlString: String) {
        if let myHomeViewController = UIApplication.currentViewController() as? MyHomeViewController {
            let diaryUUID = urlString.deletePrefix("https://tdaa.page.link")
            myHomeViewController.navigationController?.navigationBar.isHidden = true
            myHomeViewController.viewModel.updateJoinDiary(diaryUUID)
            DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
				NotificationCenter.default.post(name: .reloadDiary, object: nil)
                myHomeViewController.view.showToastMessage("다이어리가 추가되었습니다.")
            }
        } else {
            UIApplication.currentViewController()?.view.showToastMessage("다이어리 추가에 실패했습니다.")
        }
    }
    
}

