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

class PageEditModeViewController: UIViewController {
    private var completion: ((Diary, (Int,Int)) -> Void)!
    
    private lazy var newStickerDefaultSize = Layout.stickerDefaultSize
    private lazy var newStickerAppearPoint = CGPoint(x: self.view.center.x - ( self.newStickerDefaultSize.width * 0.5 ), y: self.view.center.y - self.newStickerDefaultSize.height)
    
    private let imagePickerManager = YPImagePickerManager(pickerType: .multiSelectionWithCrop)
    private var myDiariesViewModalBackgroundView = UIView()
    private var pageEditModeViewModel: PageEditModeViewModel!
    
    private let backgroundView: UIView = {
        let backgroundImageView = UIView()
        backgroundImageView.clipsToBounds = true
        backgroundImageView.isUserInteractionEnabled = true
        backgroundImageView.backgroundColor = .appBackgroundColor
        
        return backgroundImageView
    }()
    
    private lazy var docsButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "doc.on.doc", withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapDocsButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var pageDescriptionLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.stickerBackgroundColor
        label.textColor = .white
        label.textAlignment = .center
        label.font = .body
        label.layer.cornerRadius = 12.5
        label.clipsToBounds = true
        
        return label
    }()
    
    private lazy var mapToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "mappin.square", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapMapButton), for: .touchUpInside)
        
        return button
    }()
    
    private lazy var imageToolButton: UIButton = {
        let button = UIButton()
        let image = UIImage(systemName: "photo", withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapImageButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var stickerToolButton: UIButton = {
        let button = UIButton()
        guard var image = UIImage(named: "stickerTool") else { return button }
        image = image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))
        
        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapStickerButton), for: .touchUpInside)

        return button
    }()
    
    private lazy var textToolButton: UIButton = {
        let button = UIButton()
        guard var image = UIImage(named: "textTool") else { return button }
        image = image.withConfiguration(UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold))

        button.setImage(image, for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(onTapTextButton), for: .touchUpInside)

        return button
    }()
    
    // MARK: init
    init(diary: Diary, selectedPageIndex: (Int,Int), completion: @escaping (Diary, (Int,Int)) -> Void) {
        super.init(nibName: nil, bundle: nil)
        
        self.completion = completion
        self.pageEditModeViewModel = PageEditModeViewModel(diary: diary, selectedPageIndex: selectedPageIndex)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.view.backgroundColor = .appBackgroundColor
                        
            self.addSubviews()
            self.configureConstraints()

            self.configureGestureRecognizer()
            
            self.setPageDescription()
            self.setStickerViews()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.configureNavigationBar()
    }
    
    private func setPageDescription() {
        self.pageEditModeViewModel.pageIndexDescriptionObservable
            .observe(on: MainScheduler.instance)
            .bind(to: self.pageDescriptionLabel.rx.text)
            .disposed(by: self.pageEditModeViewModel.disposeBag)
    }
    
    private func setStickerViews() {
        self.pageEditModeViewModel.currentPageItemObservable
            .observe(on: MainScheduler.instance)
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
                self.backgroundView.subviews.forEach {
                    $0.removeFromSuperview()
                }
                
                stickerViews.forEach { stickerView in
                    stickerView.delegate = self
                    self.backgroundView.addSubview(stickerView)
                }
                
            })
            .disposed(by: self.pageEditModeViewModel.disposeBag)
            
    }
    
    //MARK: view 세팅 관련
    private func configureGestureRecognizer() {
        let backgroundImageViewSingleTap = UITapGestureRecognizer(target: self, action: #selector(self.setStickerSubviewHidden))
        self.backgroundView.addGestureRecognizer(backgroundImageViewSingleTap)
        
        let directions: [UISwipeGestureRecognizer.Direction] = [.right, .left]
        for direction in directions {
            let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.swipeAction(_ :)))
            gesture.direction = direction
            gesture.delegate = self
            self.view.addGestureRecognizer(gesture)
        }
    }
    
    private func configureNavigationBar() {
        let leftBarButtonItem = UIBarButtonItem(title: "LzCancel".localized, style: .plain, target: self, action: #selector(onTapNavigationCancel))
        let rightBarButtonItem = UIBarButtonItem(title: "LzDone".localized, style: .plain, target: self, action: #selector(onTapNavigationComplete))
        
        leftBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.body, NSAttributedString.Key.foregroundColor:UIColor.sandbrownColor], for: .normal)
        rightBarButtonItem.setTitleTextAttributes([NSAttributedString.Key.font: UIFont.body, NSAttributedString.Key.foregroundColor:UIColor.sandbrownColor], for: .normal)
        
        self.navigationItem.setLeftBarButton(leftBarButtonItem, animated: false)
        self.navigationItem.setRightBarButton(rightBarButtonItem, animated: false)
        
        self.navigationController?.navigationBar.barTintColor = UIColor.appBackgroundColor
        
        self.pageEditModeViewModel.selectedPageIndexSubject
            .observe(on: MainScheduler.instance)
            .map{
                "LzPageDayLabel".localizedFormat(($0.0 + 1).description)
            }
            .bind(to: self.navigationItem.rx.title)
            .disposed(by: self.pageEditModeViewModel.disposeBag)
        
		self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font: UIFont.body, NSAttributedString.Key.foregroundColor:UIColor.black]
    }

    private func addSubviews() {
        DispatchQueue.main.async {
            self.view.addSubview(self.backgroundView)
            self.view.addSubview(self.pageDescriptionLabel)
            [self.mapToolButton, self.imageToolButton, self.stickerToolButton, self.textToolButton, self.docsButton]
                .forEach{
                    self.view.addSubview($0)
                }
        }
    }
    
    private func configureConstraints() {
        DispatchQueue.main.async {
            self.backgroundView.snp.makeConstraints { make in
                make.edges.equalTo(self.view.safeAreaLayoutGuide)
            }
            
            self.pageDescriptionLabel.snp.makeConstraints { make in
                make.trailing.top.equalTo(self.backgroundView).inset(Layout.pagePadding)
                make.width.equalTo(47)
                make.height.equalTo(25)
            }
            
            self.mapToolButton.snp.makeConstraints { make in
                make.leading.equalToSuperview().offset(Layout.pagePadding)
                make.bottom.equalTo(self.backgroundView.snp.bottom).inset(Layout.pagePadding)
                make.size.equalTo(Layout.pageToolButtonSize)
            }
            
            self.imageToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.mapToolButton.snp.trailing).offset(Layout.pageToolButtonInterval)
                make.centerY.equalTo(self.mapToolButton.snp.centerY)
                make.size.equalTo(Layout.pagePhotoToolButtonSize)
            }
            
            self.stickerToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.imageToolButton.snp.trailing).offset(Layout.pageToolButtonInterval)
                make.bottom.equalTo(self.backgroundView.snp.bottom).inset(Layout.pagePadding)
                make.size.equalTo(Layout.pageToolButtonSize)
            }
            
            self.textToolButton.snp.makeConstraints { make in
                make.leading.equalTo(self.stickerToolButton.snp.trailing).offset(Layout.pageToolButtonInterval)
                make.bottom.equalTo(self.backgroundView.snp.bottom).inset(Layout.pagePadding)
                make.size.equalTo(Layout.pageToolButtonSize)
            }
            
            self.docsButton.snp.makeConstraints { make in
                make.trailing.equalToSuperview().offset( -Layout.pagePadding )
                make.centerY.equalTo(self.mapToolButton.snp.centerY)
                make.size.equalTo(Layout.pageDocsToolButtonSize)
            }
        }
    }
    
    // MARK: Actions
    @objc private func setStickerSubviewHidden() {
        
        self.backgroundView.subviews.forEach {
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
        self.imagePickerManager.presentImagePicker(viewControllerToPresent: self, completion: { images in
            self.addImageStickers(images: images)
        })
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
    
    private func addImageStickers(images: [UIImage]) {
        guard let diaryUUID = try? pageEditModeViewModel.diaryObservable.value().diaryUUID else { return }
        images.forEach {
            let imageStickerView = ImageStickerView(image: $0, diaryUUID: diaryUUID, appearPoint: newStickerAppearPoint)
            self.addSticker(stickerView: imageStickerView)
        }
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
            self.backgroundView.addSubview(stickerView)
            self.backgroundView.bringSubviewToFront(stickerView)
        }
    }
    
}

// MARK: 페이지 편집 처리
extension PageEditModeViewController {
    @objc private func onTapDocsButton() {
        let popUp = PopUpViewController(popUpPosition: .bottom2)
        popUp.addButton(buttonTitle: "LzPageAddPage".localized, buttonSymbol: "plus.square", buttonSize: 17, action: onTapAddNextPageMenu)
        popUp.addButton(buttonTitle: "LzPageDeletePage".localized, buttonSymbol: "minus.square", buttonSize: 17, action: onTapDeleteCurrentPageMenu)
        present(popUp, animated: false)
    }

    @objc private func onTapAddNextPageMenu() {
        self.pageEditModeViewModel.updateCurrentPageDataToDiaryModel(backgroundView: self.backgroundView)
        self.pageEditModeViewModel.addNewPage(to: .nextToCurrentPage)
    }
    
    @objc private func onTapDeleteCurrentPageMenu() {
        self.pageEditModeViewModel.deleteCurrentPage()
    }

    @objc private func swipeAction(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
        case .left:
            self.pageEditModeViewModel.updateCurrentPageDataToDiaryModel(backgroundView: self.backgroundView)
            self.pageEditModeViewModel.moveToNextPage()
            
        case .right:
            self.pageEditModeViewModel.updateCurrentPageDataToDiaryModel(backgroundView: self.backgroundView)
            self.pageEditModeViewModel.moveToPreviousPage()
            
        default:
            break
        }
    }

    @objc private func onTapNavigationCancel() {
        self.pageEditModeViewModel.restoreOldDiary()
        
        DispatchQueue.main.async {
            guard let diary = try? self.pageEditModeViewModel.diaryObservable.value() else  { return }
            guard let selectedPageIndex = try? self.pageEditModeViewModel.selectedPageIndexSubject.value() else  { return }
            
            self.completion(diary, selectedPageIndex)
            
            self.navigationController?.popViewController(animated: true)
        }
    }

    @objc private func onTapNavigationComplete() {
        self.pageEditModeViewModel.updateCurrentPageDataToDiaryModel(backgroundView: self.backgroundView)
        
        DispatchQueue.main.async {
            guard let diary = try? self.pageEditModeViewModel.diaryObservable.value() else  { return }
            guard let selectedPageIndex = try? self.pageEditModeViewModel.selectedPageIndexSubject.value() else  { return }
            
            self.completion(diary, selectedPageIndex)
            
            self.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK: StickerViewDelegate
extension PageEditModeViewController: StickerViewDelegate {
    
    func removeSticker(sticker: StickerView) {
        sticker.removeFromSuperview()
    }
    
    func bringStickerToFront(sticker: StickerView) {
        backgroundView.bringSubviewToFront(sticker)
    }
    
}

// MARK: PresentationDelegate
extension PageEditModeViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        
        return HalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}

// MARK: UIGestureRecognizerDelegate
extension PageEditModeViewController: UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        
        if gestureRecognizer is UISwipeGestureRecognizer {

            var result = true
            
            let point = gestureRecognizer.location(in: self.view)
            
            do {
                try self.backgroundView.subviews.forEach {
                    
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
