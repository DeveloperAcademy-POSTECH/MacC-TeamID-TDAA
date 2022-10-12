//
//  DiaryConfigViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/04.
//

import FirebaseFirestore
import MapKit
import SnapKit
import UIKit

class DiaryConfigViewController: UIViewController {
    
    enum ConfigState {
        case create
        case modify
        
        var identifier: String {
            switch self {
            case .create:
                return "추가"
            case .modify:
                return "수정"
            }
        }
    }
    
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    private var configState: ConfigState
    
    // TO REMOVE (FOR DUMMYDATA)
    private var dummyDataStartDate: Date
    
    init(mode configState: ConfigState) {
        // TO REMOVE (FOR DUMMYDATA)
        self.dummyDataStartDate = Date()
        
        self.configState = configState
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemGray5
        
        titleSetup()
        collectionViewSetup()
    }
    
    private lazy var diaryConfigCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .systemGray5
        
        collectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigCollectionViewCell")
        
        return collectionView
    }()
    
    private lazy var stateTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = device.diaryConfigTitleFont
        label.text = "다이어리 \(configState.identifier)"
        
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = device.diaryConfigButtonFont
        button.addTarget(self, action: #selector(cancelButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = device.diaryConfigButtonFont
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        return button
    }()
    
    
// MARK: - Feature methods
    @objc func cancelButtonPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: "변경사항은 저장되지 않습니다. 정말 취소하시겠습니까?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true)
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        
        let parentNavigationController: UINavigationController = self.presentingViewController as! UINavigationController
        let MyDiaryPagesVC = MyDiaryPagesViewController()
        
        presentingViewController?.dismiss(animated: true) {
            switch self.configState {
            case .create:
                // TODO: createAction 추가
                parentNavigationController.isNavigationBarHidden = false
                parentNavigationController.pushViewController(MyDiaryPagesVC, animated: true)
            case .modify:
                // TODO: modify Action 추가
                return
            }
            // TODO: 저장 Action 추가
        }
    }
    
// MARK: - Setup methods
    private func titleSetup() {
        view.addSubview(stateTitle)
        stateTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        view.addSubview(cancelButton)
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(device.diaryConfigCancelButtonLeftInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
        
        view.addSubview(doneButton)
        doneButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(device.diaryConfigDoneButtonRightInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
    }
    
    private func collectionViewSetup() {
        view.addSubview(diaryConfigCollectionView)
        diaryConfigCollectionView.snp.makeConstraints {
            $0.topMargin.equalTo(view.safeAreaLayoutGuide).inset(device.diaryConfigCollectionViewInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


// MARK: - extensions
extension DiaryConfigViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contentsCount = ConfigContentType.allCases.count
        return contentsCount
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = diaryConfigCollectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigCollectionViewCell", for: indexPath) as? DiaryConfigCollectionViewCell else { return UICollectionViewCell() }
        
        
        switch configState { // 데이터 전달 부분
        case .create:
            cell.setContent(indexPath: indexPath, diary: nil)
        case .modify:
            cell.setContent(indexPath: indexPath, diary: nil)
        }
        
        cell.contentButton?.tag = indexPath.row
        cell.contentButton?.addTarget(self, action: #selector(contentButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc func contentButtonTapped(_ sender: UIButton) {
        let configContentType = ConfigContentType.allCases[sender.tag]
        
        switch configContentType {
        case .diaryName:
            print("TextField for Diary name Configuration")
            
        case .location:
            let mapSearchViewController = MapSearchViewController()
            mapSearchViewController.completion = { mapItem in
                UIView.performWithoutAnimation {
                    sender.setTitle(mapItem.name, for: .normal)
                    sender.tintColor = .black
                    sender.layoutIfNeeded()
                }
            }
            self.present(mapSearchViewController, animated: true)
            
        case .diaryDate:
            let pickerController = CalendarPickerViewController(
                baseDate: self.dummyDataStartDate,
                selectedDateChanged: { [weak sender] date in
                    guard let sender = sender else { return }
                    self.dummyDataStartDate = date
                    UIView.performWithoutAnimation {
                        sender.setTitle(date.customFormat(), for: .normal)
                        sender.tintColor = .black
                        sender.layoutIfNeeded()
                    }
                })
            
            present(pickerController, animated: true, completion: nil)
        }
    }
}

extension DiaryConfigViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DiaryConfigViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: device.diaryConfigCollectionViewCellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: device.diaryConfigCollectionViewCellInset, left: 0, bottom: device.diaryConfigCollectionViewCellInset, right: 0)
    }
}
