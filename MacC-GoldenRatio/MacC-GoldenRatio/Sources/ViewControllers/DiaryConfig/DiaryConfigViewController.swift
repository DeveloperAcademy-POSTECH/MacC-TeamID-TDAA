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
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    private var dateInterval: [Date] = []
    var viewModel = DiaryConfigViewModel(diary: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        layout()
    }
    
    lazy var diaryConfigCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
        
        return collectionView
    }()
    
    private lazy var stateTitle: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = device.diaryConfigTitleFont
        return label
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.titleLabel?.font = device.diaryConfigButtonFont
        button.tintColor = .navigationbarColor
        return button
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("완료", for: .normal)
        button.titleLabel?.font = device.diaryConfigButtonFont
        button.tintColor = .navigationbarColor
        return button
    }()
    
    
    // MARK: - bind, setup, layout methods
    func bind(_ viewModel: DiaryConfigViewModel) {
        self.viewModel = viewModel
        
        stateTitle.text = "다이어리 \(viewModel.configState.identifier)" // TODO: observer 연결
        
        viewModel.cellData
            .drive(diaryConfigCollectionView.rx.items) { collectionView, row, data in
                switch row {
                case 0: // 다이어리 제목
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigTitleCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell.contentButton.isHidden = true
                    cell.bind(data)

                    return cell
                    
                case 1: // 장소
                    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigLocationCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell = self.mapSearchViewPresent(cell: cell, viewModel: viewModel)
                    cell.bind(data)
                    return cell
                    
                case 2: // 다이어리 날짜
                    var cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigDateCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell = self.calendarViewPresent(cell: cell, viewModel: viewModel)
                    cell.bind(data)
                    return cell
                    
                case 3: // 다이어리 색상
                    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryConfigColorCell", for: IndexPath(row: row, section: 0)) as! DiaryConfigCollectionViewCell
                    cell.contentButton.isHidden = true
                    cell.clearButton.isHidden = true
                    cell.dividerView.isHidden = true
                    cell.bind(data)
                    return cell
                    
                default:
                    fatalError()
                }
            }
            .disposed(by: disposeBag)
        
        
        viewModel.presentAlert
            .emit(onNext: { _ in
                let alertController = UIAlertController(title: nil, message: "변경사항은 저장되지 않습니다. 정말 취소하시겠습니까?", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { [weak self] _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                alertController.addAction(UIAlertAction(title: "취소", style: .cancel))
                self.present(alertController, animated: true)
            })
            .disposed(by: disposeBag)
        
        viewModel.complete
            .emit(onNext: {
                 if viewModel.checkAvailable() {
                    
                    if let parentNavigationController: UINavigationController = self.presentingViewController as? UINavigationController {
                        self.presentingViewController?.dismiss(animated: true) {
                            switch viewModel.configState {
                            case .create:
                                viewModel.addDiary()
                                NotificationCenter.default.post(name: .reloadDiary, object: nil)
                                guard let diary = viewModel.diary else { return }
                                
                                let myDiaryPagesVC = MyDiaryPagesViewController(diaryData: diary)
                                parentNavigationController.isNavigationBarHidden = false
                                parentNavigationController.pushViewController(myDiaryPagesVC, animated: true)
                                
                            case .modify:
                                viewModel.updateDiary()
                            }
                        }
                    }
                } else {
                    self.view.showToastMessage("작성이 완료되지 않았습니다.")
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
        view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
        
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigTitleCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigLocationCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigDateCell")
        diaryConfigCollectionView.register(DiaryConfigCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryConfigColorCell")
    }
    
    private func layout() {
        [stateTitle, cancelButton, doneButton, diaryConfigCollectionView].forEach {
            view.addSubview($0)
        }
        
        stateTitle.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(device.diaryConfigCancelButtonLeftInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
        
        doneButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(device.diaryConfigDoneButtonRightInset)
            $0.height.equalTo(stateTitle)
            $0.top.equalTo(stateTitle)
        }
        
        diaryConfigCollectionView.snp.makeConstraints {
            $0.topMargin.equalTo(view.safeAreaLayoutGuide).inset(device.diaryConfigCollectionViewInset)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.leading.equalTo(view.safeAreaLayoutGuide)
            $0.trailing.equalTo(view.safeAreaLayoutGuide)
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

extension DiaryConfigViewController {
    private func mapSearchViewPresent(cell: DiaryConfigCollectionViewCell, viewModel: DiaryConfigViewModel) -> DiaryConfigCollectionViewCell {
        cell.contentTap
            .subscribe(onNext: {
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
                        cell.contentButton.tintColor = .black
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
            .subscribe(onNext: {
                self.view.endEditing(true)
                
                let pickerController = CalendarPickerViewController(dateArray: self.dateInterval, selectedDateChanged: { date in
                    UIView.performWithoutAnimation {
                        let startDate = date[0]
                        let endDate = date[1]
    
                        self.dateInterval = [startDate, endDate]
                        viewModel.startDate = startDate.customFormat()
                        viewModel.endDate = endDate.customFormat()
    
                        cell.contentButton.setTitle("\(startDate.customFormat()) \(startDate.dayOfTheWeek()) - \(endDate.customFormat()) \(endDate.dayOfTheWeek())", for: .normal)
                        cell.contentButton.tintColor = .black
                        cell.contentButton.layoutIfNeeded()
                    }
                })
    
                self.present(pickerController, animated: true, completion: nil)
            })
            .disposed(by: self.disposeBag)
        
        return cell
    }
}
