//
//  MyDiaryDaysViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import MapKit // TODO: MapView 연결 이후 삭제
import RxCocoa
import RxSwift
import SnapKit
import UIKit

class MyDiaryDaysViewController: UIViewController {
    var viewModel: MyDiaryDaysViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attribute()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: animated)

        viewModel?.updateModel()
        super.viewWillAppear(animated)
    }
    
    // MARK: Components
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.labelTtitleFont2
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: configuration), for: .normal)
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "ellipsis", withConfiguration: configuration), for: .normal)
        return button
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderText
        return view
    }()
    
    let segmentedControl = DiaryDaysSegmentedControlView(items: nil)
    
    let diaryDaysCollectionView = DiaryDaysCollectionView()
    let albumCollectionView = AlbumCollectionView()
    let mapView = MapView()
    
    
    // MARK: Bind
    func bind(_ viewModel: MyDiaryDaysViewModel) {
        self.viewModel = viewModel
        
        self.segmentedControl.rx.selectedSegmentIndex
            .bind(to: viewModel.segmentIndex)
            .disposed(by: disposeBag)
                
        viewModel.selectedViewType
            .drive(onNext: { state in
                [self.diaryDaysCollectionView, self.albumCollectionView, self.mapView].enumerated().forEach { index, view in
                    view.isHidden = state[index]
                }
                
                let configuration = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular, scale: .medium)
                
                self.segmentedControl.setImage(UIImage(systemName: "doc.text.image", withConfiguration: configuration)?.withTintColor(state[0] ? .stickerBackgroundColor : .sandbrownColor , renderingMode: .alwaysOriginal), forSegmentAt: 0)
                self.segmentedControl.setImage(UIImage(systemName: "photo", withConfiguration: configuration)?.withTintColor(state[1] ? .stickerBackgroundColor : .sandbrownColor , renderingMode: .alwaysOriginal), forSegmentAt: 1)
                self.segmentedControl.setImage(UIImage(systemName: "mappin.and.ellipse", withConfiguration: configuration)?.withTintColor(state[2] ? .stickerBackgroundColor : .sandbrownColor , renderingMode: .alwaysOriginal), forSegmentAt: 2)
            })
            .disposed(by: disposeBag)
        
        viewModel.titleLabelText
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { text in self.titleLabel.text = text })
            .disposed(by: disposeBag)
        
        self.diaryDaysCollectionView.bind(viewModel.diarydaysCollectionViewModel)
        self.albumCollectionView.bind(viewModel.albumCollectionViewModel)
        self.mapView.bind(viewModel.mapViewModel)
        
        self.diaryDaysCollectionView.rx.itemSelected
            .map { $0.row }
            .subscribe(onNext: { selectedDay in
                Task {
                    let vc = await PageViewModeViewController(diary: viewModel.myDiaryDaysModel.diary, selectedDayIndex: selectedDay)
                    self.navigationController?.setNavigationBarHidden(false, animated: false)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            })
            .disposed(by: disposeBag)
        
        self.albumCollectionView.rx.itemSelected
            .subscribe(onNext: { index in
                let vc = MyAlbumPhotoViewController(photoPage: index.item, totalCount: viewModel.albumCollectionViewModel.collectionCellData.value.count)
                vc.bind(viewModel: viewModel.albumCollectionViewModel)
                vc.modalPresentationStyle = .fullScreen
                self.present(vc, animated: true)
            })
            .disposed(by: disposeBag)
        
        self.backButton.rx.tap
            .bind { self.backButtonTapped() }
            .disposed(by: disposeBag)
        
        self.menuButton.rx.tap
            .bind { self.menuButtonTapped() }
            .disposed(by: disposeBag)
    }
    
    
    // MARK: Attribute & Layout
    private func attribute() {
        self.view.backgroundColor = UIColor.appBackgroundColor
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(mapListHalfModal(notification:)), name: .mapAnnotationTapped, object: nil)
    }
    
    private func layout() {
        
        [titleLabel, backButton, menuButton, dividerView, segmentedControl].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
            $0.width.equalToSuperview().inset(100)
        }
        
        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(13)
        }
        
        menuButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(view.safeAreaLayoutGuide).inset(13)
        }
        
        dividerView.snp.makeConstraints {
            $0.top.equalTo(menuButton.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        segmentedControl.snp.makeConstraints {
            $0.top.equalTo(dividerView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(67)
        }
        
        [diaryDaysCollectionView, albumCollectionView, mapView].forEach {
            view.addSubview($0)
            $0.snp.makeConstraints{
                $0.top.equalTo(segmentedControl.snp.bottom)
                $0.bottom.width.equalToSuperview()
                $0.height.lessThanOrEqualToSuperview()
            }
        }
    }
    
    
    private func menuButtonTapped() {
        let popUp = PopUpViewController(popUpPosition: .top)
        popUp.addButton(buttonTitle: " 초대코드 복사", buttonSymbol: "envelope.arrow.triangle.branch", buttonSize: 15, action: copyButtonTapped)
        popUp.addButton(buttonTitle: " 다이어리 수정", buttonSymbol: "square.and.pencil",  buttonSize: 17, action: modifyButtonTapped)
        popUp.addButton(buttonTitle: " 다이어리 탈퇴", buttonSymbol: "door.right.hand.open",  buttonSize: 17, action: outButtonTapped)
        present(popUp, animated: false)
    }
    
    private func backButtonTapped() {
        NotificationCenter.default.post(name: .reloadDiary, object: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = self.viewModel!.myDiaryDaysModel.diary.diaryUUID
        self.view.showToastMessage("초대코드가 복사되었습니다.")
    }
    
    @objc private func modifyButtonTapped() {
        let vc = DiaryConfigViewController()
        self.viewModel?.myDiaryDaysModel.diaryDataSetup {
            self.viewModel?.diaryConfigViewModel = DiaryConfigViewModel(diary: self.viewModel?.myDiaryDaysModel.diary)
            if let viewModel = self.viewModel?.diaryConfigViewModel {
                DispatchQueue.main.async {
                    vc.bind(viewModel)
                    vc.modalPresentationStyle = .fullScreen
                    self.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func outButtonTapped() {
        let ac = UIAlertController(title: "다이어리를 나가시겠습니까?", message: "다이어리를 나가면 공동편집을 할 수 없습니다.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "다이어리 나가기", style: .destructive) { _ in
            print("다이어리 나가기")
            NotificationCenter.default.post(name: .reloadDiary, object: nil)
            self.viewModel!.myDiaryDaysModel.outCurrentDiary()
            self.backButtonTapped()
        })
        ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        present(ac, animated: true, completion: nil)
    }
    
    @objc private func mapListHalfModal(notification: NSNotification) {
        guard let day = notification.userInfo?["day"] as? Int else {
            return
        }
        
        guard let selectedLocation = notification.userInfo?["selectedLocation"] as? Location else {
            return
        }
        
        let vc = MapListViewController(viewMdoel: viewModel!.mapViewModel, day: day, selectedLocation: selectedLocation)
        let titles = viewModel!.mapViewModel.mapData
            .value
            .map { data in
                return "\(data.day)일차"
            }
        
        vc.configureSegmentedControl(titles: titles)
        
        if #available(iOS 15.0, *) {
            vc.modalPresentationStyle = .pageSheet
            if let sheet = vc.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.delegate = self
                sheet.prefersGrabberVisible = true
            }
        } else {
            vc.modalPresentationStyle = .custom
            vc.transitioningDelegate = self
        }
        vc.view.backgroundColor = .white
        
        self.present(vc, animated: true)
    }
}

extension MyDiaryDaysViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 2
    }
}

extension MyDiaryDaysViewController: UISheetPresentationControllerDelegate {
    @available(iOS 15.0, *)
    func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
        print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
    }
}

extension MyDiaryDaysViewController: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        MapHalfModalPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
