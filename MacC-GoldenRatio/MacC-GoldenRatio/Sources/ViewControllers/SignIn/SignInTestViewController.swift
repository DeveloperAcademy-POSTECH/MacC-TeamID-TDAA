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
    
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    private var uidLabel: UILabel = UILabel()
    private var emailLabel: UILabel = UILabel()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.navigationItem.hidesBackButton = true
        getUserInfo()
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: device.logInButtonFontSize)
        button.addTarget(self, action: #selector(logoutButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var withdrawalButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("회원 탈퇴", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: device.logInButtonFontSize)
        button.addTarget(self, action: #selector(withdrawalButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var diaryCreateButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("다이어리 추가", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: device.logInButtonFontSize)
        button.addTarget(self, action: #selector(diaryCreateButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var diaryModifyButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setTitle("다이어리 수정", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: device.logInButtonFontSize)
        button.addTarget(self, action: #selector(diaryModifyButtonPressed), for: .touchUpInside)
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
    
    @objc private func diaryCreateButtonPressed() {
        let vc = DiaryConfigViewController(mode: .create)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    @objc private func diaryModifyButtonPressed() {
        let vc = DiaryConfigViewController(mode: .modify)
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }
    
    // MARK: - setup
    private func testSetup() {
        view.addSubview(logoutButton)
        logoutButton.snp.makeConstraints {
            $0.size.equalTo(device.logInButtonSize)
            $0.center.equalToSuperview()
        }
        
        view.addSubview(withdrawalButton)
        withdrawalButton.snp.makeConstraints {
            $0.size.equalTo(device.logInButtonSize)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(logoutButton).offset(80)
        }
        
        view.addSubview(diaryCreateButton)
        diaryCreateButton.snp.makeConstraints {
            $0.size.equalTo(device.logInButtonSize)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(withdrawalButton).offset(80)
        }
        
        view.addSubview(diaryModifyButton)
        diaryModifyButton.snp.makeConstraints {
            $0.size.equalTo(device.logInButtonSize)
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(diaryCreateButton).offset(80)
        }
        
        view.addSubview(uidLabel)
        uidLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(logoutButton).offset(-80)
        }
        
        view.addSubview(emailLabel)
        emailLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(logoutButton).offset(-100)
        }
    }
    
    private func getUserInfo() {
        let user = Auth.auth().currentUser
        if let user = user {
            let uid = user.uid
            let email = user.email
            
            uidLabel.text = "uid: \(uid)"
            uidLabel.textColor = .black
            emailLabel.text = "이메일: \(String(describing: email!))"
            emailLabel.textColor = .black
        }
    }
}
