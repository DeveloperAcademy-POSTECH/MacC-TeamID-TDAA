//
//  SignInViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/29.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setup()
    }
    
    // MARK: - properties
    
    private lazy var appleLoginButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .black
        button.tintColor = .white
        button.setImage(UIImage(systemName: "applelogo"), for: .normal)
        button.setPreferredSymbolConfiguration(.init(pointSize: 28, weight: .regular, scale: .default), forImageIn: .normal)
        button.setTitle(" Apple ID로 로그인", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        return button
    }()
    
    // MARK: - feature methods
    
    @objc private func appleLoginButtonPressed() {
        print("Sign In completed with Apple ID")
    }
    
    // MARK: - setup
    
    private func setup() {
        view.addSubview(appleLoginButton)
        appleLoginButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
