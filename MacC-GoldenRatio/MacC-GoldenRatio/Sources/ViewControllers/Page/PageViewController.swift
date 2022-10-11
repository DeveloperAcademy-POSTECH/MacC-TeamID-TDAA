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
    private var isEditMode = false {
        willSet{
            switch newValue {
            case true:
                self.configureEditMode()
            case false:
                self.configureViewingMode()
            }
        }
    }
    
    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        backgroundImageView.clipsToBounds = true
        backgroundImageView.isUserInteractionEnabled = false

        return backgroundImageView
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = myDevice.pageDescriptionLabelFont
        let selectedDay = pageViewModel.selectedDay
        let currentPageString = (pageViewModel.currentPageIndex + 1).description
        let currentDayPageCount = pageViewModel.diary.diaryPages[selectedDay].pages.count.description
        let labelText = currentPageString + "/" + currentDayPageCount
        label.text = labelText
        
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

        self.configureImagePicker()
        DispatchQueue.main.async {
            self.configureViewingMode()
            self.addSubviews()
            self.configureBackgroundImageViewGestureRecognizer()
            self.configureToolButton()
            self.configureConstraints()
            self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
            self.setStickerSubviewHidden()
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
                $0.delegate = self
                self.backgroundImageView.addSubview($0)
            }
        }
    }
    
    private func configureBackgroundImageViewGestureRecognizer() {
        let backgroundImageViewSingleTap = UITapGestureRecognizer(target: self, action: #selector(self.setStickerSubviewHidden))
        self.backgroundImageView.addGestureRecognizer(backgroundImageViewSingleTap)
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(_ :)))
            gesture.direction = direction
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
        }
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
    
    private func configureImagePicker() {
        self.imagePicker.sourceType = .photoLibrary
        self.imagePicker.allowsEditing = true
        self.imagePicker.delegate = self
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
    
    @objc private func setStickerSubviewHidden() {
        self.pageViewModel.stickerSubviewHidden(true)
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
    
    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            if pageViewModel.currentPageIndex + 2 <= pageViewModel.stickerArray.count {
                self.pageViewModel.currentPageIndex += 1
                self.backgroundImageView.subviews.forEach{
                    $0.removeFromSuperview()
                }
                self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
            } else {
                print("마지막 페이지입니다.")
            }
        case .right:
            if pageViewModel.currentPageIndex - 1 >= 0 {
                self.pageViewModel.currentPageIndex -= 1
                self.backgroundImageView.subviews.forEach{
                    $0.removeFromSuperview()
                }
                self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
            } else {
                print("첫 페이지입니다.")
            }
        default:
            break
        }
    }
    
    // MARK: Completion Method
    private func addMapSticker(mapItem: MKMapItem) {
        let mapStickerView = MapStickerView(mapItem: mapItem)
        self.addSticker(stickerView: mapStickerView)
        self.pageViewModel.appendSticker(mapStickerView)

    }
    
    private func addImageSticker(image: UIImage?) {
        guard let image = image else { return }
        let imageStickerView = ImageStickerView(image: image, diaryUUID: pageViewModel.diary.diaryUUID)
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
        }
    }

}

// MARK: NavigtionItemActions
extension PageViewController {
    
    @objc private func onTapNavigationBack() {
        self.dismiss(animated: false)
    }
    
    @objc private func onTapNavigationEdit() {
        self.isEditMode = true
    }
    
    @objc private func onTapNavigationCancel() {
        self.isEditMode = false
    }
    
    // TODO: await 처리해주기
    @objc private func onTapNavigationComplete() {
        self.isEditMode = false

        pageViewModel.stickerSubviewHidden(true)
        pageViewModel.updateDBPages()
    }
    
    private func configureEditMode() {
        self.backgroundImageView.isUserInteractionEnabled = true

        [mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            $0.isHidden = false
        }
        self.tabBarController?.tabBar.isHidden = true
        let leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onTapNavigationCancel))
        let rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(onTapNavigationComplete))
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
    }
    
    private func configureViewingMode() {
        self.navigationItem.title = (pageViewModel.selectedDay + 1).description + "일차"
        self.backgroundImageView.isUserInteractionEnabled = false

        [mapToolButton, imageToolButton, stickerToolButton, textToolButton].forEach{
            $0.isHidden = true
        }
        
        self.tabBarController?.tabBar.isHidden = true
        let leftBarButtonItem = UIBarButtonItem(title: "이전", style: .plain, target: self, action: #selector(onTapNavigationBack))
        let rightBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(onTapNavigationEdit))
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
    }
}


// MARK: StickerViewDelegate
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

// MARK: UIGestureRecognizerDelegate
extension PageViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is UISwipeGestureRecognizer && isEditMode == false {
            return true
        }
        return false
    }
}
