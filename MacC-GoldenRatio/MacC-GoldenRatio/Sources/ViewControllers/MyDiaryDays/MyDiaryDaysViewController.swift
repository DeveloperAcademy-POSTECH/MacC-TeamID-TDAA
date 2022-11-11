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
    private var viewModel: MyDiaryDaysViewModel?
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attribute()
        layout()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
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
    
    private lazy var segmentedControl: UISegmentedControl = {
        let configuration = UIImage.SymbolConfiguration(pointSize: 20, weight: .regular, scale: .medium)
        let dayButton = UIImage(systemName: "doc.text.image", withConfiguration: configuration) ?? UIImage()
        let albumButton = UIImage(systemName: "photo", withConfiguration: configuration) ?? UIImage()
        let mapButton = UIImage(systemName: "mappin.and.ellipse", withConfiguration: configuration) ?? UIImage()
        let control = UISegmentedControl(items: [dayButton, albumButton, mapButton])
        let selectedAttribute = [NSAttributedString.Key.foregroundColor: UIColor.sandbrownColor]
        control.setTitleTextAttributes(selectedAttribute, for:.selected)
        control.selectedSegmentIndex = 0
        control.backgroundColor = .clear
        return control
    }()

    let diaryDaysCollectionView = DiaryDaysCollectionView()
    let albumCollectionView = AlbumCollectionView()
    let mapView = MKMapView()
    
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
            })
            .disposed(by: disposeBag)
        
        self.diaryDaysCollectionView.bind(viewModel.diarydaysCollectionViewModel)
        self.albumCollectionView.bind(viewModel.albumCollectionViewModel)
        
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
        
        self.titleLabel.text = viewModel.myDiaryDaysModel.diary.diaryName
    }
    
    // MARK: Attribute & Layout
    private func attribute() {
        // TODO: UIColor+ 추가 후 수정
        self.view.backgroundColor = UIColor(named: "appBackgroundColor")!
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
        
        
    }
    
    private func layout() {
        
        [titleLabel, backButton, menuButton, dividerView, segmentedControl].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalTo(backButton)
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
            $0.height.equalTo(44)
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
        self.navigationController?.popViewController(animated: false)
    }
    
    @objc private func copyButtonTapped() {
        UIPasteboard.general.string = self.viewModel!.myDiaryDaysModel.diary.diaryUUID
        self.view.showToastMessage("초대코드가 복사되었습니다.")
    }
    
    @objc private func modifyButtonTapped() {
        let vc = DiaryConfigViewController()
        vc.bind(DiaryConfigViewModel(diary: self.viewModel!.myDiaryDaysModel.diary))
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
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
}

extension MyDiaryDaysViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 2
    }
}
