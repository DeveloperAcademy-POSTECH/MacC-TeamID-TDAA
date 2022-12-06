//
//  DiaryConfigViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/02.
//

import FirebaseFirestore
import MapKit
import RxSwift
import RxCocoa
import SnapKit
import UIKit

class DiaryConfigViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private var dateInterval: [Date] = []
    private let imagePickerManager = YPImagePickerManager(pickerType: .coverWithCrop)
    var viewModel = DiaryConfigViewModel(diary: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    lazy var diaryConfigCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        collectionView.backgroundColor = UIColor.beige100
        
        return collectionView
    }()
    
    private lazy var divider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.placeholderText
        return view
    }()
    
    private lazy var stateTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = .body
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .body
        button.setTitle("LzCancel".localized, for: .normal)
        button.tintColor = .beige600
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = .body
        button.setTitle("LzDone".localized, for: .normal)
        button.tintColor = .beige600
        return button
    }()
    
    
    // MARK: - bind, setup, layout methods
    func bind(_ viewModel: DiaryConfigViewModel) {
        self.viewModel = viewModel
        
        stateTitle.text = "LzDiaryConfigTitle".localizedFormat(" \(viewModel.configState.identifier)")
        
        viewModel.cellData
            .drive(diaryConfigCollectionView.rx.items) { collectionView, row, data in
                switch data.configContentType {
                case .diaryName: // 다이어리 제목
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigTitleCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell.bind(data)
                    return cell
                    
                case .location: // 장소
                    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigLocationCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell = self.mapSearchViewPresent(cell: cell, viewModel: viewModel)
                    cell.bind(data)
                    return cell
                    
                case .diaryDate: // 다이어리 날짜
                    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigDateCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell = self.calendarViewPresent(cell: cell, viewModel: viewModel)
                    cell.bind(data)
                    return cell
                    
                case .diaryColor: // 다이어리 색상
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigColorCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell.bind(data)
                    return cell
                    
                case .diaryImage: // 표지 이미지
                    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigImageCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell = self.modalPresent(cell: cell, viewModel: viewModel)
                    viewModel.diaryCoverImage
                        .subscribe(onNext: {
                            viewModel.coverImage = $0
                            cell.contentButton.setImage($0.withCornerRadius($0.size.height / 8.5), for: .normal)
                        })
                        .disposed(by: self.disposeBag)
                    cell.bind(data)
                    return cell
                }
            }
            .disposed(by: disposeBag)
        
        
        viewModel.presentAlert
            .emit(onNext: { _ in
                let alertController = UIAlertController(title: nil, message: viewModel.configState.alertMessage, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "LzConfirm".localized, style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "LzCancel".localized, style: .cancel))
                self.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        
        
        viewModel.complete
            .drive(onNext: {
                if viewModel.checkAvailable() {
                    self.dismiss()
                } else {
                    self.view.showToastMessage("LzDiaryConfigIncomplete".localized)
                }
            })
            .disposed(by: disposeBag)
        
        viewModel.textfieldEndEdit // 완료 버튼 눌렀을 때 키보드 닫기
            .emit(onNext: { self.view.endEditing(true) })
            .disposed(by: self.disposeBag)
        
        cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        doneButton.rx.tap
            .bind(to: viewModel.doneButtonTapped)
            .disposed(by: disposeBag)
    }
    
    private func setup() {
        let tapGesture = UITapGestureRecognizer(target: view, action: #selector(UIView.endEditing))
        view.addGestureRecognizer(tapGesture)
        tapGesture.cancelsTouchesInView = false
        view.backgroundColor = UIColor.beige100
        
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigTitleCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigLocationCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigDateCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigColorCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigImageCell")
    }
    
    private func layout() {
        [stateTitle, cancelButton, doneButton, divider, diaryConfigCollectionView].forEach {
            view.addSubview($0)
        }
        
        stateTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(Layout.diaryConfigCancelButtonLeftInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
        
        doneButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(Layout.diaryConfigDoneButtonRightInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
        
        divider.snp.makeConstraints {
            $0.bottom.equalTo(stateTitle).offset(9)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        diaryConfigCollectionView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(16)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

extension DiaryConfigViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var cellHeight: CGFloat = 86
        
        switch viewModel.configState {
        case .create:
            if indexPath.row == 3 { cellHeight = 166 }
            else if indexPath.row == 4 { cellHeight = 225 }
        case .modify:
            if indexPath.row == 2 { cellHeight = 166 }
            else if indexPath.row == 3 { cellHeight = 225 }
        }
        return CGSize(width: UIScreen.main.bounds.width, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: -5, left: 0, bottom: -5, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

extension DiaryConfigViewController {
    // MARK: Parent & Child View Presentation Related Methods
    
    private func dismiss() {
        if let parentNavigationController: UINavigationController = self.presentingViewController as? UINavigationController {
            self.presentingViewController?.dismiss(animated: true) {
                
                self.viewModel.uploadImage() {
                    switch self.viewModel.configState {
                    case .create:
                        self.viewModel.addDiary()
                        NotificationCenter.default.post(name: .reloadDiary, object: nil)
                        guard let diary = self.viewModel.diary else { return }
                
                        let myDiaryDaysVC = MyDiaryDaysViewController()
                        let myDiaryDaysVM = MyDiaryDaysViewModel(diary: diary)
                        myDiaryDaysVC.bind(myDiaryDaysVM)
                        parentNavigationController.isNavigationBarHidden = false
                        parentNavigationController.pushViewController(myDiaryDaysVC, animated: true)
                        
                    case .modify:
                        self.viewModel.updateDiary { print("다이어리 업로드 완료: \(self.viewModel.diary?.diaryName ?? "이름없음")") }
                        NotificationCenter.default.post(name: .reloadDiary, object: nil)
                    }
                }
            }
        }
    }
    
    private func mapSearchViewPresent(cell: DiaryConfigCollectionViewCell, viewModel: DiaryConfigViewModel) -> DiaryConfigCollectionViewCell {
        cell.contentTap
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: {
                self.view.endEditing(true)
                
                let mapSearchViewController = MapSearchViewController()
                mapSearchViewController.completion = { mapItem in
                    UIView.performWithoutAnimation {
                        let locationName = mapItem.name
                        let locationAddress = mapItem.placemark.countryCode
                        let locationCoordinate = mapItem.placemark.location?.coordinate
                        let locationCategory = mapItem.pointOfInterestCategory?.rawValue.description ?? ""
                        let location = Location(locationName: locationName ?? "", locationAddress: locationAddress ?? "", locationCoordinate: [Double(locationCoordinate?.latitude ?? 0.0), Double(locationCoordinate?.longitude ?? 0.0)], locationCategory: locationCategory)
                        
                        viewModel.location = location
                        
                        cell.contentButton.setTitle(locationName, for: .normal)
                        cell.contentButton.setTitleColor(.black, for: .normal)
                        cell.contentButton.layoutIfNeeded()
                    }
                }
                self.present(mapSearchViewController, animated: true)
            })
            .disposed(by: self.disposeBag)
        
        return cell
    }
    
    private func calendarViewPresent(cell: DiaryConfigCollectionViewCell, viewModel: DiaryConfigViewModel) -> DiaryConfigCollectionViewCell {
        cell.contentTap
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: {
                self.view.endEditing(true)
                
                let pickerController = CalendarPickerViewController(dateArray: self.dateInterval, selectedDateChanged: { date in
                    UIView.performWithoutAnimation {
                        let startDate = date[0]
                        let endDate = date[1]
                        
                        self.dateInterval = [startDate, endDate]
                        viewModel.startDate = startDate.customFormat()
                        viewModel.endDate = endDate.customFormat()
                        cell.contentButton.setTitle("\(startDate.customFormat()) (\(startDate.dayOfTheWeek())) - \(endDate.customFormat()) (\(endDate.dayOfTheWeek()))", for: .normal)
                        cell.contentButton.setTitleColor(.black, for: .normal)
                        cell.contentButton.layoutIfNeeded()
                    }
                })
                self.present(pickerController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        return cell
    }
    
    private func modalPresent(cell: DiaryConfigCollectionViewCell, viewModel: DiaryConfigViewModel) -> DiaryConfigCollectionViewCell {
        
        cell.contentTap
            .asDriver(onErrorJustReturn: Void())
            .drive(onNext: {
                if viewModel.coverImage != UIImage(named: "selectImage") {
                    let alertController = UIAlertController(title: "LzDiaryConfigSetImage".localized, message: nil, preferredStyle: .actionSheet)
                    
                    alertController.addAction(UIAlertAction(title: "LzDiaryConfigAlbum".localized, style: .default, handler: { [weak self] _ in
                        self?.view.endEditing(true)
                        self?.presentImagePicker()
                    }))
                    alertController.addAction(UIAlertAction(title: "LzDiaryConfigDefaultImage".localized, style: .default, handler: { [weak self] _ in
                        self?.viewModel.resetCoverImage()
                        self?.viewModel.coverImage = UIImage(named: "selectImage") ?? UIImage()
                    }))
                    alertController.addAction(UIAlertAction(title: "LzCancel".localized, style: .cancel))
                    self.present(alertController, animated: true)
                } else {
                    self.view.endEditing(true)
                    self.presentImagePicker()
                }
            })
            .disposed(by: self.disposeBag)
        
        return cell
    }
    
    private func presentImagePicker() {
        self.imagePickerManager.presentImagePicker(viewControllerToPresent: self, completion: { images in
            self.viewModel.diaryCoverImage.accept(images[0])
            self.viewModel.coverImage = images[0]
        })
    }
}
