//
//  PageViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import UIKit
import SnapKit

class PageViewController: UIViewController {
    private var stickers: [StickerView] = []
    private let pageDescriptionLabelFont: UIFont = UIFont.systemFont(ofSize: 17, weight: .regular)
    private let toolSize: CGSize = CGSize(width: 30, height: 30)
    private let toolButtonPointSize: CGFloat = 18

    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        
        return backgroundImageView
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = pageDescriptionLabelFont
        label.text = "1 / 15"
        
        return label
    }()
    
    private lazy var mapToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "map")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    private lazy var imageToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "photo")
        button.setImage(image, for: .normal)
        button.tintColor = .black

        return button
    }()
    
    private lazy var stickerToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "s.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        
        return button
    }()
    
    private lazy var textToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "t.square")
        button.setImage(image, for: .normal)
        button.tintColor = .black

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.main.async {
            self.addSubviews()
            self.configureBackgroundImageView()
            self.configureToolButton()
            self.configureConstraints()
        }
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(pageDescriptionLabel)
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            view.addSubview($0)
        }
    }
    
    private func configureBackgroundImageView() {
        let backgroundImageViewSingleTap = UITapGestureRecognizer(target: self, action: #selector(self.setStickerSubviewIsHidden))
        self.backgroundImageView.addGestureRecognizer(backgroundImageViewSingleTap)
    }
    
    private func configureToolButton() {
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: toolButtonPointSize)
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.preferredSymbolConfigurationForImage = imageConfig
                $0.configuration = config
            } else {
                $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
            }
            
        }
        self.mapToolButton.addTarget(self, action: #selector(self.addSticker), for: .touchUpInside)
        self.imageToolButton.addTarget(self, action: #selector(self.addSticker), for: .touchUpInside)
        self.stickerToolButton.addTarget(self, action: #selector(self.addSticker), for: .touchUpInside)
        self.textToolButton.addTarget(self, action: #selector(self.addSticker), for: .touchUpInside)
    }
    
    private func configureConstraints() {
        [backgroundImageView, pageDescriptionLabel, mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
        
        backgroundImageView.snp.makeConstraints { make in
            make.leading.top.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageDescriptionLabel.snp.makeConstraints { make in
            make.trailing.top.equalTo(backgroundImageView).inset(10)
        }
        
        mapToolButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(10)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(10)
            make.size.equalTo(toolSize)
        }
        
        imageToolButton.snp.makeConstraints { make in
            make.leading.equalTo(mapToolButton.snp.trailing).offset(10)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(10)
            make.size.equalTo(toolSize)
        }
        
        stickerToolButton.snp.makeConstraints { make in
            make.leading.equalTo(imageToolButton.snp.trailing).offset(10)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(10)
            make.size.equalTo(toolSize)
        }
        
        textToolButton.snp.makeConstraints { make in
            make.leading.equalTo(stickerToolButton.snp.trailing).offset(10)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(10)
            make.size.equalTo(toolSize)
        }
    }
    
    // MARK: Actions
    @objc private func addSticker() {
        DispatchQueue.main.async {
            let image = UIImage(systemName: "photo")!
            let stickerView = StickerView(image: image, size: CGSize(width: 100, height: 100))
            stickerView.center = self.backgroundImageView.center
            self.backgroundImageView.addSubview(stickerView)
            self.backgroundImageView.bringSubviewToFront(stickerView)
            self.backgroundImageView.isUserInteractionEnabled = true
            self.stickers.append(stickerView)
        }
        
    }
    
    @objc private func setStickerSubviewIsHidden() {
        stickers.forEach{
            $0.subviewIsHidden = true
        }
    }
}
