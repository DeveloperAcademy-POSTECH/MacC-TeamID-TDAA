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
    private let pageViewModel = PageViewModel()
    private let imagePicker = UIImagePickerController()

    private lazy var backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        backgroundImageView.clipsToBounds = true

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
        button.addTarget(self, action: #selector(onTapStickerButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var textToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "t.square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapTextButton), for: .touchUpInside)

        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tabBarController?.tabBar.isHidden = true
        let leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: nil)
        let rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(onTapNavigationComplete))
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
            self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
        }
    }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(pageDescriptionLabel)
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            view.addSubview($0)
        }
    }
    
    private func loadStickerViews(pageIndex: Int) {
        DispatchQueue.main.async {
            self.pageViewModel.stickerArray[pageIndex].forEach{
                print($0)
                $0.delegate = self
                self.backgroundImageView.addSubview($0)
                self.backgroundImageView.isUserInteractionEnabled = true
            }
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
    @objc private func onTapNavigationComplete() {
        // TODO: await 처리해주기
        pageViewModel.hideStickerSubviews()
        pageViewModel.updateDBPages()
    }
    
    @objc private func setStickerSubviewIsHidden() {
        self.pageViewModel.hideStickerSubviews()
    }
    
    @objc private func onTapMapButton() {
        let mapSearchViewController = MapSearchViewController()
        mapSearchViewController.completion = self.addMapSticker(mapItem:)
        self.present(mapSearchViewController, animated: true)
    }
    
    @objc func onTapImageButton() {
        self.present(self.imagePicker, animated: true)
    }
    
    @objc func onTapStickerButton(){
        let stickerPickerViewController = StickerPickerViewController()
        stickerPickerViewController.completion = self.addSticker(sticker:)
        stickerPickerViewController.modalPresentationStyle = .custom
        stickerPickerViewController.transitioningDelegate = self
        self.present(stickerPickerViewController, animated: true)
    }
    
    @objc func onTapTextButton() {
        self.addTextSticker()
    }
    
    // MARK: Completion Method
    private func addMapSticker(mapItem: MKMapItem) {
        let mapStickerView = MapStickerView(mapItem: mapItem)
        self.addSticker(stickerView: mapStickerView)
        self.pageViewModel.appendSticker(mapStickerView)

    }
    
    private func addImageSticker(image: UIImage?) {
        guard let image = image else { return }
        let imageStickerView = ImageStickerView(image: image)
        self.addSticker(stickerView: imageStickerView)
        self.pageViewModel.appendSticker(imageStickerView)

    }
    
    private func addSticker(sticker: String) {
        let imageStickerView = StickerStickerView(sticker: sticker)
        self.addSticker(stickerView: imageStickerView)
        self.pageViewModel.appendSticker(imageStickerView)
    }
    
    private func addTextSticker() {
        let textStickerView = TextStickerView()
        self.addSticker(stickerView: textStickerView)
        self.pageViewModel.appendSticker(textStickerView)
    }
    
    private func addSticker(stickerView: StickerView) {
        DispatchQueue.main.async {
            stickerView.delegate = self
            stickerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
            self.backgroundImageView.addSubview(stickerView)
            self.backgroundImageView.bringSubviewToFront(stickerView)
            self.backgroundImageView.isUserInteractionEnabled = true
        }
    }

}

extension PageViewController: StickerViewDelegate {
    func removeSticker(sticker: StickerView) {
        sticker.removeFromSuperview()
        pageViewModel.removeSticker(sticker)
    }
    
    func bringToFront(sticker: StickerView) {
        backgroundImageView.bringSubviewToFront(sticker)
        pageViewModel.bringStickerToFront(sticker)
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

// MARK: PresentationDelegate
extension PageViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
