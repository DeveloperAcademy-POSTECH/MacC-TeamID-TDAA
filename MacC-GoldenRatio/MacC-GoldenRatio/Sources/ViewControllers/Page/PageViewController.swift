//
//  PageViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import MapKit
import SnapKit
import UIKit

class PageViewController: UIViewController {
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    private let pageViewModel = PageViewModel.pageViewModel
    private let imagePicker = UIImagePickerController()

    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        
        return backgroundImageView
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = myDevice.pageDescriptionLabelFont
        label.text = "1 / 15"
        
        return label
    }()
    
    private lazy var mapToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "map")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapMapButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var imageToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "photo")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapImageButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var stickerToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "s.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapMapButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var textToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "t.square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapMapButton), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        let leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
        let rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: nil)
        self.navigationItem.title = "1일차"
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
        
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
            
            let imageConfig = UIImage.SymbolConfiguration(pointSize: myDevice.pageToolButtonPointSize)
            if #available(iOS 15.0, *) {
                var config = UIButton.Configuration.plain()
                config.preferredSymbolConfigurationForImage = imageConfig
                $0.configuration = config
            } else {
                $0.setPreferredSymbolConfiguration(imageConfig, forImageIn: .normal)
            }
            
        }
    }
    
    private func configureConstraints() {
        
        backgroundImageView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        pageDescriptionLabel.snp.makeConstraints { make in
            make.trailing.top.equalTo(backgroundImageView).inset(myDevice.pagePadding)
        }
        
        mapToolButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(myDevice.pagePadding)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(myDevice.pagePadding)
            make.size.equalTo(myDevice.pageToolButtonSize)
        }
        
        imageToolButton.snp.makeConstraints { make in
            make.leading.equalTo(mapToolButton.snp.trailing).offset(myDevice.pageToolButtonInterval)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(myDevice.pagePadding)
            make.size.equalTo(myDevice.pageToolButtonSize)
        }
        
        stickerToolButton.snp.makeConstraints { make in
            make.leading.equalTo(imageToolButton.snp.trailing).offset(myDevice.pageToolButtonInterval)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(myDevice.pagePadding)
            make.size.equalTo(myDevice.pageToolButtonSize)
        }
        
        textToolButton.snp.makeConstraints { make in
            make.leading.equalTo(stickerToolButton.snp.trailing).offset(myDevice.pageToolButtonInterval)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(myDevice.pagePadding)
            make.size.equalTo(myDevice.pageToolButtonSize)
        }
    }
    
    // MARK: Actions
    @objc private func setStickerSubviewIsHidden() {
        self.pageViewModel.hideStickerSubviews()
    }
    
    @objc private func onTapMapButton() {
        let mapSearchViewController = MapSearchViewController()
        mapSearchViewController.completion = self.addMapSticker(mapItem:)
        self.present(mapSearchViewController, animated: true)
    }
    
    @objc func onTapImageButton(){
        self.present(self.imagePicker, animated: true)
    }
    
    // MARK: Completion Method
    private func addMapSticker(mapItem: MKMapItem) {
        let mapStickerView = StickerView(mapItem: mapItem, size: self.myDevice.stickerDefaultSize)
        self.addSticker(stickerView: mapStickerView)
    }
    
    private func addImageSticker(image: UIImage?) {
        guard let image = image else { return }
        let mapStickerView = StickerView(image: image, size: self.myDevice.stickerDefaultSize)
        self.addSticker(stickerView: mapStickerView)
    }
    
    private func addSticker(stickerView: StickerView) {
        DispatchQueue.main.async {
            stickerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
            self.backgroundImageView.addSubview(stickerView)
            self.backgroundImageView.bringSubviewToFront(stickerView)
            self.backgroundImageView.isUserInteractionEnabled = true
            self.pageViewModel.appendSticker(stickerView)
        }
    }

}
// MARK: ImagePikcerDelegate
extension PageViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        var selectedImage: UIImage? = nil
        
        if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            selectedImage = image
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
        }
        self.addImageSticker(image: selectedImage)
        self.imagePicker.dismiss(animated: true, completion: nil)
    }
}
