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
    private var viewModel = DiaryConfigViewModel()
    private var diaryToConfig: Diary?
    private var dateInterval: [Date] = []
    
    init(mode configState: ConfigState, diary: Diary?) {
        self.configState = configState
        switch configState {
        case .create:
            print("New Diary Page")
        case .modify:
            self.diaryToConfig = diary
            self.viewModel.getDiaryData(diary: self.diaryToConfig!)
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 자연스러운 TextFiled를 위한 gesture
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
        
        titleSetup()
        collectionViewSetup()
        textFieldSetup()
    }
    
    private lazy var diaryConfigCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
        
        collectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigCollectionViewCell")
        
        return collectionView
    }()
    
    lazy var contentTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "다이어리 이름을 입력해주세요."
        textField.text = diaryToConfig?.diaryName ?? nil
        textField.font = UIFont(name: "EF_Diary", size: 17)
        textField.returnKeyType = .done
        textField.becomeFirstResponder()
        textField.delegate = self
        return textField
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
        button.tintColor = .navigationbarColor
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = device.diaryConfigButtonFont
        button.addTarget(self, action: #selector(doneButtonPressed), for: .touchUpInside)
        button.tintColor = .navigationbarColor
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
        self.contentTextField.endEditing(true)
        
        if viewModel.checkAvailable() {
            
            if let parentNavigationController: UINavigationController = self.presentingViewController as? UINavigationController {
                presentingViewController?.dismiss(animated: true) {
                    switch self.configState {
                    case .create:
                        self.viewModel.addDiary()
						NotificationCenter.default.post(name: .reloadDiary, object: nil)
                        let myDiaryPagesVC = MyDiaryPagesViewController(diaryData: self.viewModel.diary!)
                        parentNavigationController.isNavigationBarHidden = false
                        parentNavigationController.pushViewController(myDiaryPagesVC, animated: true)
                        
                    case .modify:
                        self.viewModel.updateDiary()
                    }
                }
            }
        } else {
            self.view.showToastMessage("작성이 완료되지 않았습니다.")
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
    
    private func textFieldSetup() {
        view.addSubview(contentTextField)
        contentTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(device.diaryConfigCellLeftInset)
            $0.trailing.equalToSuperview().inset(50)
            $0.height.equalTo(44)
            $0.top.equalTo(diaryConfigCollectionView.snp.top).inset(62)
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
        
        switch configState {
        case .create:
            return ConfigContentType.allCases.count
        case .modify:
            return ConfigContentType.allCases.count - 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = diaryConfigCollectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigCollectionViewCell", for: indexPath) as? DiaryConfigCollectionViewCell else { return UICollectionViewCell() }
        
        
        switch configState { // 데이터 전달 부분
        case .create:
            cell.setContent(indexPath: indexPath, diary: nil)
        case .modify:
            cell.setContent(indexPath: indexPath, diary: diaryToConfig)
        }
        
        cell.contentButton.tag = indexPath.row
        cell.clearButton.tag = indexPath.row
        
        cell.contentButton.addTarget(self, action: #selector(contentButtonTapped), for: .touchUpInside)
        cell.clearButton.addTarget(self, action: #selector(clearButtonTapped), for: .touchUpInside)
        return cell
    }
    
    @objc func contentButtonTapped(_ sender: UIButton) {
        let configContentType = ConfigContentType.allCases[sender.tag]
        
        switch configContentType {
        case .diaryName:
            sender.setTitle("", for: .normal)
            textFieldSetup()
            
        case .location:
            self.contentTextField.endEditing(true)
            
            let mapSearchViewController = MapSearchViewController()
            mapSearchViewController.completion = { mapItem in
                UIView.performWithoutAnimation {
                    let locationName = mapItem.name
                    let locationAddress = mapItem.placemark.countryCode
                    let locationCoordinate = mapItem.placemark.location?.coordinate
                    
                    self.viewModel.location = Location(locationName: locationName ?? "", locationAddress: locationAddress ?? "", locationCoordinate: [Double(locationCoordinate?.latitude ?? 0.0), Double(locationCoordinate?.longitude ?? 0.0)])
                    
                    sender.setTitle(locationName, for: .normal)
                    sender.tintColor = .black
                    sender.layoutIfNeeded()
                }
            }
            self.present(mapSearchViewController, animated: true)
            
        case .diaryDate:
            self.contentTextField.endEditing(true)
            
            let pickerController = CalendarPickerViewController(dateArray: dateInterval, selectedDateChanged: { [self, weak sender] date in
                guard let sender = sender else { return }
                UIView.performWithoutAnimation {
                    let startDate = date[0]
                    let endDate = date[1]
                    
                    dateInterval = [startDate, endDate]
                    self.viewModel.startDate = startDate.customFormat()
                    self.viewModel.endDate = endDate.customFormat()
                    
                    sender.setTitle("\(startDate.customFormat()) \(startDate.dayOfTheWeek())  - \(endDate.customFormat()) \(endDate.dayOfTheWeek())", for: .normal)
                    sender.tintColor = .black
                    sender.layoutIfNeeded()
                }
            })
            
            present(pickerController, animated: true, completion: nil)
        }
    }
    
    @objc func clearButtonTapped(_ sender: UIButton) {
        let configContentType = ConfigContentType.allCases[sender.tag]
        
        switch configContentType {
        case .diaryName:
            self.contentTextField.text = nil
            self.contentTextField.endEditing(true)
        case .location:
            UIView.performWithoutAnimation {
                let contentButton = self.diaryConfigCollectionView.viewWithTag(sender.tag) as? UIButton ?? UIButton()
                contentButton.setTitle("여행지를 입력해주세요.", for: .normal)
                contentButton.tintColor = .placeholderText
            }
            self.contentTextField.endEditing(true)
        case .diaryDate:
            UIView.performWithoutAnimation {
                let contentButton = self.diaryConfigCollectionView.viewWithTag(sender.tag) as? UIButton ?? UIButton()
                contentButton.setTitle("여행한 날짜를 선택해주세요.", for: .normal)
                contentButton.tintColor = .placeholderText
            }
            self.contentTextField.endEditing(true)
        }
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

extension DiaryConfigViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.endEditing(true)
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.viewModel.title = textField.text
    }
}
