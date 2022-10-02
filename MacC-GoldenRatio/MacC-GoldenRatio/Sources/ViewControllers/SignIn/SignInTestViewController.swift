//
//  SignInTestViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/30.
//

import FirebaseAuth
import SnapKit
import UIKit

// window.rootViewController = UINavigationController(rootViewController: SignInViewController())

class SignInTestViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.hidesBackButton = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        // Firebase Test setup (Logout, Withdrawal)
        testSetup()
    }
    
    // MARK: - UI & Features for test
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var withdrawalButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("회원 탈퇴", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.addTarget(self, action: #selector(withdrawalButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
    // MARK: - feature methods
    @objc private func logoutButtonPressed() {
        let firebaseAuth = Auth.auth()
        
        do{
            try firebaseAuth.signOut()
            print("Sign Out completed with Apple ID")
            self.navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("ERROR: signOut \(signOutError.localizedDescription)")
        }
    }
    
    @objc private func withdrawalButtonPressed() {
        let user = Auth.auth().currentUser
        
        user?.delete { error in
            if let withdrawalError = error {
                print("ERROR: withdrawal \(withdrawalError.localizedDescription)")
            } else {
                print("Withdrawal completed with Apple ID")
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    // MARK: - setup
    private func testSetup() {
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.center.equalToSuperview()
        }
        
        view.addSubview(withdrawalButton)
        withdrawalButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(logoutButton).offset(80)
        }
    }
}
