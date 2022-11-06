//
//  PageViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import RxSwift
import RxCocoa
import MapKit
import SnapKit
import UIKit

// PageEditModeViewController
class PageViewController: UIViewController {
    private lazy var newStickerDefaultSize = UIScreen.getDevice().stickerDefaultSize
    private lazy var newStickerAppearPoint = CGPoint(x: self.view.center.x - ( self.newStickerDefaultSize.width * 0.5 ), y: self.view.center.y - self.newStickerDefaultSize.height)
    
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    private let imagePicker = UIImagePickerController()
    private var myDiariesViewModalBackgroundView = UIView()
    private var pageViewModel: PageViewModel!
    
    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        backgroundImageView.clipsToBounds = true
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.backgroundColor = .diaryInnerTexture
        
        return backgroundImageView
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .navigationTitleFont
        
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
    
    // MARK: init
    init(diary: Diary, selectedDay: Int) async {
        super.init(nibName: nil, bundle: nil)
        self.pageViewModel = await PageViewModel(diary: diary, selectedDay: selectedDay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.view.backgroundColor = .backgroundTexture
            self.configureImagePicker()
                        
            self.addSubviews()
            self.configureConstraints()

            self.configureGestureRecognizer()
            self.configureToolButton()
            
            self.setPageDescription()
            self.setStickerViews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigation()
    }
    
    private func setPageDescription() {
        self.pageViewModel.pageIndexDescriptionObservable
            .subscribe(on: MainScheduler.instance)
            .bind(to: self.pageDescriptionLabel.rx.text)
            .disposed(by: self.pageViewModel.disposeBag)
    }
    
    private func setStickerViews() {
        self.pageViewModel.currentPageItemObservable
            .subscribe(on: MainScheduler.instance)
            .map { items in
                
                let stickerViews: [StickerView] = items.map { item in
                    
                    switch item.itemType {
                    case .text:
                        return TextStickerView(item: item)
                    case .image:
                        return ImageStickerView(item: item)
                    case .sticker:
                        return StickerStickerView(item: item)
                    case .location:
                        return MapStickerView(item: item)
                    }
                    
                }
                
                return stickerViews
            }
            .subscribe(onNext: { stickerViews in
                
                self.backgroundImageView.subviews.forEach {
                    $0.removeFromSuperview()
                }
                
                stickerViews.forEach { stickerView in
                    
                    stickerView.delegate = self
                    debugPrint(stickerView.frame)
                    self.backgroundImageView.addSubview(stickerView)
                }
                
            })
            .disposed(by: self.pageViewModel.disposeBag)
            
    }
    
    //MARK: view 세팅 관련
    private func configureGestureRecognizer() {
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
    
    private func configureNavigation() {
        let leftBarButtonItem = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(onTapNavigationCancel))
        let rightBarButtonItem = UIBarButtonItem(title: "완료", style: .plain, target: self, action: #selector(onTapNavigationComplete))
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.pageViewModel.selectedDay
            .subscribe(on: MainScheduler.instance)
            .map{
                ($0 + 1).description + "일차"
            }
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.pageViewModel.disposeBag)
        
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.black]
    }

    private func addSubviews() {
        DispatchQueue.main.async {
            self.view.addSubview(self.backgroundImageView)
            self.view.addSubview(self.pageDescriptionLabel)
            [self.mapToolButton, self.imageToolButton, self.stickerToolButton, self.textToolButton]
                .forEach{
                    self.view.addSubview($0)
                }
        }
    }
    
    private func configureConstraints() {
        DispatchQueue.main.async {
            self.backgroundImageView.snp.makeConstraints { make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            }
            
            self.pageDescriptionLabel.snp.makeConstraints { make in
                make.trailing.top.equalTo(self.backgroundImageView).inset(self.myDevice.pagePadding)
            }
            
            self.mapToolButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(self.myDevice.pagePadding)
                make.bottom.equalTo(self.backgroundImageView.snp.bottom).inset(self.myDevice.pagePadding)
                make.size.equalTo(self.myDevice.pageToolButtonSize)
            }
            
            self.imageToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.mapToolButton.snp.trailing).offset(self.myDevice.pageToolButtonInterval)
                make.bottom.equalTo(self.backgroundImageView.snp.bottom).inset(self.myDevice.pagePadding)
                make.size.equalTo(self.myDevice.pageToolButtonSize)
            }
            
            self.stickerToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.imageToolButton.snp.trailing).offset(self.myDevice.pageToolButtonInterval)
                make.bottom.equalTo(self.backgroundImageView.snp.bottom).inset(self.myDevice.pagePadding)
                make.size.equalTo(self.myDevice.pageToolButtonSize)
            }
            
            self.textToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.stickerToolButton.snp.trailing).offset(self.myDevice.pageToolButtonInterval)
                make.bottom.equalTo(self.backgroundImageView.snp.bottom).inset(self.myDevice.pagePadding)
                make.size.equalTo(self.myDevice.pageToolButtonSize)
            }
        }
    }
    
    // MARK: Actions
    @objc private func setStickerSubviewHidden() {
        
        self.backgroundImageView.subviews.forEach {
            if let stickerView = $0 as? StickerView {
                stickerView.isStickerViewActive.onNext(false)
            }
        }
        
    }
    
    @objc private func onTapMapButton() {
        let mapSearchViewController = MapSearchViewController()
        mapSearchViewController.completion = self.addMapSticker(mapItem:)
        self.present(mapSearchViewController, animated: true)
    }
    
    @objc func onTapImageButton() {
        imagePicker.modalPresentationStyle = .overCurrentContext
        
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
        let mapStickerView = MapStickerView(mapItem: mapItem, appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: mapStickerView)
    }
    
    private func addImageSticker(image: UIImage?) {
        guard let image = image else { return }
        guard let diaryUUID = try? pageViewModel.diaryObservable.value().diaryUUID else { return }
        let imageStickerView = ImageStickerView(image: image, diaryUUID: diaryUUID, appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: imageStickerView)
    }
    
    private func addSticker(sticker: String) {
        let imageStickerView = StickerStickerView(sticker: sticker, appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: imageStickerView)
    }
    
    private func addTextSticker() {
        let textStickerView = TextStickerView(appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: textStickerView)
    }
    
    private func addSticker(stickerView: StickerView) {
        DispatchQueue.main.async {
            stickerView.delegate = self
            self.backgroundImageView.addSubview(stickerView)
            self.backgroundImageView.bringSubviewToFront(stickerView)
        }
    }
}

// MARK: 페이지 편집 처리
extension PageViewController {
//    @objc private func onTapDocsButton() {
//        let popUp = PopUpViewController(popUpPosition: .bottom2)
//        popUp.addButton(buttonTitle: "페이지 추가", action: onTapAddPageToLastMenu)
//        popUp.addButton(buttonTitle: "페이지 삭제", action: onTapDeletePageMenu)
//        present(popUp, animated: false)
//    }
//
//    private func onTapAddPageToLastMenu() {
//        pageViewModel.addNewPage()
//        pageViewModel.currentPageIndex = pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count - 1
//        reloadStickers()
//        reloadPageDescriptionLabel()
//    }
//
//    private func onTapDeletePageMenu() {
//        guard pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count > 1 else {
//            print("한 장입니다.")
//            return
//        }
//        pageViewModel.deletePage()
//        if pageViewModel.currentPageIndex - 1 == pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count - 1 {
//            pageViewModel.currentPageIndex -= 1
//        }
//        reloadStickers()
//        reloadPageDescriptionLabel()
//    }
    
    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            self.pageViewModel.moveToNextPage()
           
        case .right:
            self.pageViewModel.moveToPreviousPage()
            
        default:
            break
        }
    }
    
//    @objc private func onTapNavigationBack() {
//        self.navigationController?.popViewController(animated: false)
//        self.dismiss(animated: false)
//    }
//
//    @objc private func onTapNavigationEdit() {
//        pageViewModel.saveOldData()
//        self.isEditMode = true
//    }

    @objc private func onTapNavigationCancel() {
//            self.pageViewModel.restoreOldData()
        // TODO: 이전 diary data를 diarySubject에 onNext로 심어주기

    }

    @objc private func onTapNavigationComplete() {
       
        // TODO: diarySubject의 value를 서버에 올리기
//        pageViewModel.updateDBPages()
    }
}

// MARK: StickerViewDelegate
extension PageViewController: StickerViewDelegate {
    
    func removeSticker(sticker: StickerView) {
        sticker.removeFromSuperview()
    }
    
    func bringStickerToFront(sticker: StickerView) {
        backgroundImageView.bringSubviewToFront(sticker)
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
        
        if gestureRecognizer is UISwipeGestureRecognizer {

            var result = true
            
            let point = gestureRecognizer.location(in: self.view)
            
            do {
                try self.backgroundImageView.subviews.forEach {
                    
                    let convertedPoint = $0.convert(point, from: self.view)
                    
                    if let stickerView = $0 as? StickerView {
                        
                        if try stickerView.isStickerViewActive.value() && stickerView.bounds.contains(convertedPoint) {
                            
                            result = false
                            return
                        }
                        
                    }
                    
                }
            } catch {
                print(error)
            }

            return result
        }
        
        return true
    }

}
