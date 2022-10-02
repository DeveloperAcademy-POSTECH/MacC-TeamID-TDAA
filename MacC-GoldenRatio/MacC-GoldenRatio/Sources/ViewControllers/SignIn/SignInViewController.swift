//
//  SignInViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/29.
//

import UIKit
import SnapKit
import AuthenticationServices

class SignInViewController: UIViewController {
    
    let myImageView:UIImageView = UIImageView()
    
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
        button.setPreferredSymbolConfiguration(.init(pointSize: 21.4),forImageIn: .normal)
        button.setTitle("  Apple로 로그인", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 21.4)
        button.addTarget(self, action: #selector(appleLoginButtonPressed), for: .touchUpInside)
        button.layer.cornerRadius = 4
        return button
    }()
    
    // MARK: - feature methods
    
    @objc private func appleLoginButtonPressed() {
        print("Sign In completed with Apple ID")
        
        showTestView()
    }
    
    func showTestView() {
        let signInTestVC = SignInTestViewController()
        self.navigationController?.pushViewController(signInTestVC, animated: true)
    }
    
    // MARK: - setup
    
    private func setup() {
        view.addSubview(appleLoginButton)
        
        appleLoginButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 268, height: 50))
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().inset(80)
        }

    }
    
}
