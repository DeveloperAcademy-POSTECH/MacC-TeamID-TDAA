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
                        print("HomeViewController")
                        let myHomeViewController = currentViewController as! MyHomeViewController
                        let diaryUUID = urlString.deletePrefix("https://tdaa.page.link")
                        myHomeViewController.viewModel.updateJoinDiary(diaryUUID)
                        myHomeViewController.reloadDiaryCell()
                        myHomeViewController.view.showToastMessage("다이어리가 추가되었습니다.")
                    } else if currentViewController is SignInViewController {
                        print("SignInViewController")
                    } else {
                        print("VC: \(UIApplication.currentViewController()!)")
                    }
                    print(urlString)
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
    
}

