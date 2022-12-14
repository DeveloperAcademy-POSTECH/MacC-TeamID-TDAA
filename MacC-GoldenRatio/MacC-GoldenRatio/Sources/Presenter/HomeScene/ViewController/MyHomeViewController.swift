//
//  MyDiariesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

final class MyHomeViewController: UIViewController, UIGestureRecognizerDelegate {
	private let disposeBag = DisposeBag()
    let viewModel = MyHomeViewModel()
	
	private var currentLongPressedCell: DiaryCollectionViewCell?
	
	private lazy var collectionHeaderView = DiaryCollectionHeaderView()
	private lazy var collectionView = DiaryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout(), viewModel: viewModel.diaryCollectionViewModel)
	private lazy var addDiaryButton = HomeButtonView()
	private lazy var profileButton = HomeButtonView()
	private lazy var dateFilterButton = FilterButton()
	private lazy var nameFilterButton = FilterButton()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupSubViews()
		bind()
		setupGestureRecognizer()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupSubViews() {
        self.view.backgroundColor = UIColor.beige100

		[collectionHeaderView, collectionView, addDiaryButton, profileButton, dateFilterButton, nameFilterButton].forEach { view.addSubview($0) }
		
		collectionHeaderView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(25)
		}
		
		collectionView.snp.makeConstraints {
			$0.top.equalTo(collectionHeaderView.snp.bottom).offset(90)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
			$0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(10)
		}
		
        dateFilterButton.setTitle("LzHomeDateFilter".localized, for: .normal)
		dateFilterButton.backgroundColor = .beige600
		dateFilterButton.setTitleColor(.white, for: .normal)
		dateFilterButton.snp.makeConstraints {
			$0.width.equalTo(53)
			$0.height.equalTo(26)
			$0.top.equalTo(collectionHeaderView.snp.bottom).offset(55)
			$0.leading.equalToSuperview().inset(20)
		}
		
        nameFilterButton.setTitle("LzHomeNameFilter".localized, for: .normal)
		nameFilterButton.backgroundColor = .white
		nameFilterButton.setTitleColor(.beige600, for: .normal)
		nameFilterButton.snp.makeConstraints {
			$0.width.equalTo(53)
			$0.height.equalTo(26)
			$0.top.equalTo(collectionHeaderView.snp.bottom).offset(55)
			$0.leading.equalTo(dateFilterButton.snp.trailing).offset(10)
		}
		
		addDiaryButton.setupViews(UIImage(named: "plusButton"))
		addDiaryButton.snp.makeConstraints {
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(Layout.addDiaryButtonPadding)
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
		}
		
		let image = UIImage(
			systemName: "person.circle",
			withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)
		)?.withTintColor(UIColor.beige600, renderingMode: .alwaysOriginal)
		profileButton.setupViews(image)
		profileButton.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(25)
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}

	}
	
	private func bind() {
		collectionView.bind()
		collectionView.rx
			.modelSelected(Diary.self)
			.subscribe(onNext: { diary in
				let vc = MyDiaryDaysViewController()
				vc.bind(MyDiaryDaysViewModel(diary: diary))
				self.navigationController?.pushViewController(vc, animated: true)
			})
			.disposed(by: disposeBag)
		
		addDiaryButton.rx.tap
			.bind {
				if !self.viewModel.longPressedEnabled.value {
					self.addDiaryButton.setImage(UIImage(named: "closeButton"), for: .normal)
					let popUp = PopUpViewController(popUpPosition: .bottom)
                    popUp.addButton(buttonTitle: "LzHomeCreate".localized, buttonSymbol: "doc.badge.plus", buttonSize: 17, action: self.createButtonTapped)
                    popUp.addButton(buttonTitle: "LzHomeJoin".localized, buttonSymbol: "envelope.open", buttonSize: 15, action: self.joinButtonTapped)
					self.present(popUp, animated: false)
				} else {
					self.endEditMode()
				}
			}
			.disposed(by: disposeBag)
	  
		profileButton.rx.tap
			.bind {
				if !self.viewModel.longPressedEnabled.value {
					let vc = MyPageViewController()
					self.navigationController?.pushViewController(vc, animated: true)
				} else {
					self.endEditMode()
				}
			}
			.disposed(by: disposeBag)
		
		dateFilterButton.rx.tap
			.bind {
				self.dateFilterButton.backgroundColor = .beige600
				self.dateFilterButton.setTitleColor(.white, for: .normal)
				self.nameFilterButton.backgroundColor = .white
				self.nameFilterButton.setTitleColor(.beige600, for: .normal)
				Observable.just(true)
					.bind(to: self.viewModel.filterButtonTapped)
					.disposed(by: self.disposeBag)
			}
			.disposed(by: disposeBag)
		
		nameFilterButton.rx.tap
			.bind {
				self.dateFilterButton.backgroundColor = .white
				self.dateFilterButton.setTitleColor(.beige600, for: .normal)
				self.nameFilterButton.backgroundColor = .beige600
				self.nameFilterButton.setTitleColor(.white, for: .normal)
				Observable.just(false)
					.bind(to: self.viewModel.filterButtonTapped)
					.disposed(by: self.disposeBag)
			}
			.disposed(by: disposeBag)
		
		viewModel.diaryCollectionViewModel.removeData
			.bind { data in
				if data != nil {
                    let ac = UIAlertController(title: "LzOutAlertTitle".localized, message: "LzOutAlertMessage".localized, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "LzOutAlertOut".localized, style: .destructive) { _ in
						self.viewModel.diaryCollectionViewModel.outCurrentDiary(data!.diaryUUID, data!.userUIDs)
						NotificationCenter.default.post(name: .reloadDiary, object: nil)
					})
                    ac.addAction(UIAlertAction(title: "LzCancel".localized, style: .cancel, handler: nil))
					self.present(ac, animated: true, completion: nil)
				}
			}
			.disposed(by: disposeBag)
		
		NotificationCenter
			.default
			.rx
			.notification(.reloadDiary)
			.subscribe(onNext: { _ in
				self.viewModel.createCell()
			})
			.disposed(by: disposeBag)
		
		NotificationCenter
			.default
			.rx
			.notification(.changeAddButtonImage)
			.subscribe(onNext: { _ in
				self.addDiaryButton.setImage(UIImage(named: "plusButton"), for: .normal)
			})
			.disposed(by: disposeBag)
	}
	
	private func setupGestureRecognizer() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
		tapGesture.cancelsTouchesInView = false
		viewModel.longPressedEnabled
			.asObservable()
			.subscribe(onNext: { value in
				if value {
					self.view.addGestureRecognizer(tapGesture)
				} else {
					self.view.removeGestureRecognizer(tapGesture)
				}
			})
			.disposed(by: disposeBag)
		
		let longPressedGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(gestureRecognizer:)))
		longPressedGesture.minimumPressDuration = 0.4
		longPressedGesture.delegate = self
		longPressedGesture.delaysTouchesBegan = true
		collectionView.addGestureRecognizer(longPressedGesture)
	}
	
	func endEditMode() {
		Observable.just(false)
			.bind(to: viewModel.longPressedEnabled)
			.disposed(by: disposeBag)
		viewModel.createCell()
	}
	
	@objc func tapGesture() {
		endEditMode()
	}
	
	@objc func handleLongPress(gestureRecognizer: UILongPressGestureRecognizer) {
		Observable.just(true)
			.bind(to: viewModel.longPressedEnabled)
			.disposed(by: disposeBag)
		viewModel.createCell()
	}
	
	@objc func createButtonTapped() {
		let vc = DiaryConfigViewController()
		vc.bind(DiaryConfigViewModel(diary: nil))
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true, completion: nil)
	}
	
	@objc func joinButtonTapped() {
        let joinDiaryAlert = UIAlertController(title: "LzHomeJoinAlertTitle".localized, message: "LzHomeJoinAlertMessage".localized, preferredStyle: .alert)
        let joinAction = UIAlertAction(title: "LzConfirm".localized, style: .default) { action in
			if let textField = joinDiaryAlert.textFields?.first {
				self.viewModel.isDiaryCodeEqualTo(textField.text ?? "")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
					if self.viewModel.isEqual {
						self.viewModel.updateJoinDiary(textField.text ?? "")
						self.viewModel.createCell()
                        self.view.showToastMessage("LzHomeJoinAlertAdded".localized)
					} else {
                        self.view.showToastMessage("LzHomeJoinAlertWrong".localized)
					}
				}
				self.dismiss(animated: true, completion: nil)
			}
		}
        let cancelAction = UIAlertAction(title: "LzCancel".localized, style: .cancel) { action in
			self.dismiss(animated: true, completion: nil)
		}
		joinDiaryAlert.addTextField()
		joinDiaryAlert.addAction(joinAction)
		joinDiaryAlert.addAction(cancelAction)
		self.present(joinDiaryAlert, animated: true)
	}
}

extension MyHomeViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		MapHalfModalPresentationController(presentedViewController: presented, presenting: presenting)
	}
}
