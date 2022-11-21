//
//  LicenseViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/16.
//

import SnapKit
import UIKit

class LicenseViewController: UIViewController {

    private let textView: UITextView = {
        let textView = UITextView()
        textView.textColor = .black
        textView.isUserInteractionEnabled = true
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        return textView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .backgroundTexture
        setUI()
    }
    
    private func setUI() {
        view.addSubview(textView)
        textView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
        
        if let path = Bundle.main.path(forResource: "License", ofType: "txt") {
            do {
                let text = try String(contentsOfFile: path, encoding: String.Encoding.utf8)
                textView.text = text
            } catch {
                print("Failed to read text from License")
            }
        } else {
            print("Failed to load file from app bundle License")
        }
    }
}
