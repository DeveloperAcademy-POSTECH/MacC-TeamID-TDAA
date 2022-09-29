//
//  SignInViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/09/29.
//

import UIKit
import SnapKit

class SignInViewController: UIViewController {
    var appleLogInButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        appleLogInButton = UIButton(type: .system)
        appleLogInButton.backgroundColor = .white
        appleLogInButton.tintColor = .black
        appleLogInButton.layer.cornerRadius = 15
        appleLogInButton.layer.borderColor = UIColor.black.cgColor
        appleLogInButton.setImage(UIImage(systemName: "applelogo"), for: .normal)
        appleLogInButton.setPreferredSymbolConfiguration(.init(pointSize: 28, weight: .regular, scale: .default), forImageIn: .normal)
        appleLogInButton.setTitle(" Apple ID로 로그인", for: .normal)
        appleLogInButton.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        appleLogInButton.addTarget(self, action: #selector(appleLogInButtonPressed), for: .touchUpInside)
        view.addSubview(appleLogInButton)
        
        appleLogInButton.snp.makeConstraints {
            $0.size.equalTo(CGSize(width: 300, height: 50))
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    @objc func appleLogInButtonPressed() {
        
    }
}
