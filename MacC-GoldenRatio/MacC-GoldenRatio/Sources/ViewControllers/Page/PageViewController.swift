//
//  PageViewController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import Combine
import MapKit
import SnapKit
import UIKit

enum pageViewMode {
    case edit
    case view
}

class PageViewController: UIViewController {
    private lazy var newStickerAppearPoint = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
    
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    private let imagePicker = UIImagePickerController()
    private var myDiariesViewModalBackgroundView = UIView()
    private var pageViewModel: PageViewModel!
        
    private var isEditMode = false {
        willSet{
            switch newValue {
            case true:
                self.configurePageViewMode(mode: .edit)
            case false:
                self.configurePageViewMode(mode: .view)
            }
        }
    }
    
    private let backgroundImageView: UIImageView = {
        let backgroundImageView = UIImageView()
        backgroundImageView.backgroundColor = .gray
        backgroundImageView.clipsToBounds = true
        backgroundImageView.isUserInteractionEnabled = false
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
        button.isHidden = true
        
        return button
    }()
    
    private lazy var imageToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "photo")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapImageButton), for: .touchUpInside)
        button.isHidden = true

        return button
    }()
    
    private lazy var stickerToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "s.circle.fill")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapStickerButton), for: .touchUpInside)
        button.isHidden = true

        return button
    }()
    
    private lazy var textToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "t.square")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapTextButton), for: .touchUpInside)
        button.isHidden = true

        return button
    }()
    
    private lazy var docsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "doc.on.doc")
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapDocsButton), for: .touchUpInside)
        button.isHidden = true

        return button
    }()
    
    // MARK: init
    init(diary: Diary, selectedDay: Int) {
        super.init(nibName: nil, bundle: nil)
        self.pageViewModel = PageViewModel(diary: diary, selectedDay: selectedDay)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.view.backgroundColor = .backgroundTexture
//            self.setupViewModel()
            self.configureImagePicker()
            self.reloadPageDescriptionLabel()
            self.addSubviews()
            self.configureGestureRecognizer()
            self.configureToolButton()
            self.configureConstraints()
            self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
            self.setStickerSubviewHidden()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.backgroundImageView.isUserInteractionEnabled = false
        self.configureNavigation()
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
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton, docsButton].forEach{
            
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
        let leftBarButtonItem = UIBarButtonItem(title: "이전", style: .plain, target: self, action: #selector(onTapNavigationBack))
        let rightBarButtonItem = UIBarButtonItem(title: "편집", style: .plain, target: self, action: #selector(onTapNavigationEdit))
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.navigationbarColor], for: .normal)
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        self.navigationItem.title = (pageViewModel.selectedDay + 1).description + "일차"
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.navigationTitleFont, NSAttributedString.Key.foregroundColor:UIColor.black]
    }
    
    private func configurePageViewMode(mode: pageViewMode) {
        let isToolHidden: Bool!
        let leftBarButtonItem = self.navigationItem.leftBarButtonItem
        let rightBarButtonItem = self.navigationItem.rightBarButtonItem
        
        switch mode {
        case .edit:
            isToolHidden = false
            leftBarButtonItem?.title = "취소"
            leftBarButtonItem?.action = #selector(onTapNavigationCancel)
            
            rightBarButtonItem?.title = "완료"
            rightBarButtonItem?.action = #selector(onTapNavigationComplete)
            
        case .view:
            isToolHidden = true
            leftBarButtonItem?.title = "이전"
            leftBarButtonItem?.action = #selector(onTapNavigationBack)
            
            rightBarButtonItem?.title = "편집"
            rightBarButtonItem?.action = #selector(onTapNavigationEdit)
        }
        self.backgroundImageView.isUserInteractionEnabled = !isToolHidden
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton, docsButton].forEach{
            $0.isHidden = isToolHidden
        }
      }
    
    private func addSubviews() {
        view.addSubview(backgroundImageView)
        view.addSubview(pageDescriptionLabel)
        [mapToolButton, imageToolButton, stickerToolButton, textToolButton, docsButton].forEach{
            view.addSubview($0)
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
        
        docsButton.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-myDevice.pagePadding)
            make.bottom.equalTo(backgroundImageView.snp.bottom).inset(myDevice.pagePadding)
            make.size.equalTo(myDevice.pageToolButtonSize)
        }
    }
    
    // MARK: Actions
    @objc private func setStickerSubviewHidden() {
        self.pageViewModel.hideStickerSubview(true)
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
        self.pageViewModel.appendSticker(mapStickerView)

    }
    
    private func addImageSticker(image: UIImage?) {
        guard let image = image else { return }
        let imageStickerView = ImageStickerView(image: image, diaryUUID: pageViewModel.diary.diaryUUID, appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: imageStickerView)
        self.pageViewModel.appendSticker(imageStickerView)
    }
    
    private func addSticker(sticker: String) {
        let imageStickerView = StickerStickerView(sticker: sticker, appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: imageStickerView)
        self.pageViewModel.appendSticker(imageStickerView)
    }
    
    private func addTextSticker() {
        let textStickerView = TextStickerView(appearPoint: newStickerAppearPoint)
        self.addSticker(stickerView: textStickerView)
        self.pageViewModel.appendSticker(textStickerView)
    }
    
    private func addSticker(stickerView: StickerView) {
        DispatchQueue.main.async {
            stickerView.delegate = self
//            stickerView.center = CGPoint(x: self.view.center.x, y: self.view.center.y - 100)
            self.backgroundImageView.addSubview(stickerView)
            self.backgroundImageView.bringSubviewToFront(stickerView)
        }
    }
}

// MARK: 스티커 로딩 처리
extension PageViewController {
    
    private func reloadStickers() {
        DispatchQueue.main.async {
            self.backgroundImageView.subviews.forEach{
                $0.removeFromSuperview()
            }
            self.loadStickerViews(pageIndex: self.pageViewModel.currentPageIndex)
            self.pageViewModel.hideStickerSubview(true)
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
    
    private func reloadPageDescriptionLabel() {
        let selectedDay = pageViewModel.selectedDay
        let currentPageString = (pageViewModel.currentPageIndex + 1).description
        let currentDayPageCount = pageViewModel.diary.diaryPages[selectedDay].pages.count.description
        let labelText = currentPageString + "/" + currentDayPageCount
        pageDescriptionLabel.text = labelText
    }
}

// MARK: 페이지 편집 처리
extension PageViewController {
    @objc private func onTapDocsButton() {
        let popUp = PopUpViewController(popUpPosition: .bottom2)
        popUp.addButton(buttonTitle: "페이지 추가", action: onTapAddPageToLastMenu)
        popUp.addButton(buttonTitle: "페이지 삭제", action: onTapDeletePageMenu)
        present(popUp, animated: false)
    }
    
    private func onTapAddPageToLastMenu() {
        pageViewModel.addNewPage()
        pageViewModel.currentPageIndex = pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count - 1
        reloadStickers()
        reloadPageDescriptionLabel()
    }

    private func onTapDeletePageMenu() {
        guard pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count > 1 else {
            print("한 장입니다.")
            return
        }
        pageViewModel.deletePage()
        if pageViewModel.currentPageIndex - 1 == pageViewModel.diary.diaryPages[pageViewModel.selectedDay].pages.count - 1 {
            pageViewModel.currentPageIndex -= 1
        }
        reloadStickers()
        reloadPageDescriptionLabel()
    }
    
    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            if pageViewModel.currentPageIndex + 2 <= pageViewModel.stickerArray.count {
                pageViewModel.currentPageIndex += 1
                reloadStickers()
                reloadPageDescriptionLabel()
            } else {
                print("마지막 페이지입니다.")
            }
        case .right:
            if pageViewModel.currentPageIndex - 1 >= 0 {
                pageViewModel.currentPageIndex -= 1
                reloadStickers()
                reloadPageDescriptionLabel()
            } else {
                print("첫 페이지입니다.")
            }
        default:
            break
        }
    }
    
    @objc private func onTapNavigationBack() {
        self.navigationController?.popViewController(animated: false)
        self.dismiss(animated: false)
    }
    
    @objc private func onTapNavigationEdit() {
        pageViewModel.saveOldData()
        self.isEditMode = true
    }

    @objc private func onTapNavigationCancel() {
        DispatchQueue.main.async {
            self.isEditMode = false
            self.pageViewModel.restoreOldData()
            self.pageViewModel.setStickerArray()
            self.reloadStickers()
            self.reloadPageDescriptionLabel()
        }
    }

    // TODO: await 처리해주기
    @objc private func onTapNavigationComplete() {
        self.isEditMode = false
        self.pageViewModel.hideStickerSubview(true)
        if pageViewModel.currentPageIndex == 0 {
            guard let thumbnailImage = self.backgroundImageView.transformToImage() else { return }
            pageViewModel.upLoadThumbnail(image: thumbnailImage) {
                self.pageViewModel.updatePageThumbnail()
                self.pageViewModel.updateDBPages()
            }
        } else {
            pageViewModel.updateDBPages()
        }
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
//// MARK: Combine
//private extension PageViewController {
//    func setupViewModel() {
//        pageViewModel.$currentPageIndex
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//
//            }
//            .store(in: &cancelBag)
//
//        pageViewModel.$selectedDay
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//
//            }
//            .store(in: &cancelBag)
//
//        pageViewModel.$diary
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//
//            }
//            .store(in: &cancelBag)
//
//        pageViewModel.$stickerArray
//            .receive(on: DispatchQueue.main)
//            .sink { [weak self] _ in
//                self?.reloadStickers()
//            }
//            .store(in: &cancelBag)
//    }
//}
