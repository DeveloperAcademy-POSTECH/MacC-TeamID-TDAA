//
//  DiaryConfigViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/04.
//

import SnapKit
import UIKit

class DiaryConfigViewController: UIViewController {
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    private var configState: ConfigState
    
    let dummyData = [Diary(diaryUUID: "", diaryName: "🌊포항항", diaryLocation: Location(locationName: "포항", locationAddress: "포항시", locationCoordinate: [36.0190, 129.3435]), diaryStartDate: Date(), diaryEndDate: Date(timeIntervalSinceNow: 86400), diaryPages: [[Page(pageUUID: "", items: [Item(itemUUID: "", itemType: ItemType.text, contents: "", itemSize: [0.0], itemPosition: [0.0], itemAngle: 0.0)])]], userUIDs: [User(userUID: "", userName: "칼리", userImageURL: ""), User(userUID: "", userName: "드록바", userImageURL: ""), User(userUID: "", userName: "해츨링", userImageURL: ""), User(userUID: "", userName: "라우", userImageURL: ""), User(userUID: "", userName: "산", userImageURL: "")])]
    
    init(mode configState: ConfigState) {
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

        collectionView.backgroundColor = .systemBackground
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
    
    
    // MARK: - feature methods
    @objc func cancelButtonPressed(_ sender: UIButton) {
        let ac = UIAlertController(title: nil, message: "변경사항은 저장되지 않습니다. 정말 취소하시겠습니까?", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "취소", style: .cancel))
        ac.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
            self?.dismiss(animated: true, completion: nil)
        }))
        present(ac, animated: true)
    }
    
    @objc func doneButtonPressed(_ sender: UIButton) {
        // 다이어리 저장
        self.dismiss(animated: true, completion: nil)
    }
    
// MARK: - feature methods
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
            $0.topMargin.equalTo(view.safeAreaLayoutGuide).inset(40)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
        }
    }
}


// MARK: - extensions
extension DiaryConfigViewController: UICollectionViewDataSource {
    internal func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let contentsCount = ConfigContentType.allCases.count
        return contentsCount
    }
    
    internal func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = diaryConfigCollectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigCollectionViewCell", for: indexPath) as? DiaryConfigCollectionViewCell else { return UICollectionViewCell() }
        
        switch configState {
        case .create:
            cell.setContent(indexPath: indexPath, diary: nil)
        case .modify:
            cell.setContent(indexPath: indexPath, diary: dummyData[0])
        }
        
        return cell
    }
}

extension DiaryConfigViewController: UICollectionViewDelegate {
    internal func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
}

extension DiaryConfigViewController: UICollectionViewDelegateFlowLayout {
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 86)
    }
    
    internal func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
    }
}

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
