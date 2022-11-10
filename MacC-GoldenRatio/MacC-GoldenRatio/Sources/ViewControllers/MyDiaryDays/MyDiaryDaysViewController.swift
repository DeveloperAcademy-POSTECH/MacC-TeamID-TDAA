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
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        attribute()
        layout()
    }
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "다이어리 이름"
        label.font = UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        let configuration = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold, scale: .medium)
        button.tintColor = .black
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: configuration), for: .normal)
        button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside) // TODO: Button Action Rx 분리
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
        control.selectedSegmentIndex = 0
        return control
    }()
    
    let diaryDaysCollectionView = UIView()
    let albumCollectionView = AlbumCollectionView()
    let mapView = MKMapView()
    
    // MARK: Bind
    func bind(_ viewModel: MyDiaryDaysViewModel) {
        
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
        
        self.albumCollectionView.bind(viewModel.albumCollectoinViewModel)
    }
    
    // MARK: Attribute & Layout
    private func attribute() {
        self.view.backgroundColor = .white
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
    
    
    @objc private func backButtonTapped() {
        NotificationCenter.default.post(name: .reloadDiary, object: nil)
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.popViewController(animated: true)
    }
}

extension MyDiaryDaysViewController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return navigationController?.viewControllers.count ?? 0 > 2
    }
}
