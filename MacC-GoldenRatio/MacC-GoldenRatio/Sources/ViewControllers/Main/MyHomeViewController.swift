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

final class MyHomeViewController: UIViewController {
	private let disposeBag = DisposeBag()
	private let viewModel = MyHomeViewModel()
	private let myDevice = UIScreen.getDevice()
	
	private lazy var collectionView = DiaryCollectionView()
	private lazy var addDiaryButton = HomeButtonView()
	private lazy var profileButton = HomeButtonView()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupSubViews()
		bind()
		setupNotification()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupSubViews() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())

		[collectionView, addDiaryButton, profileButton].forEach { view.addSubview($0) }
		collectionView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.bottom.leading.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
		addDiaryButton.setupViews(UIImage(named: "plusButton"))
		addDiaryButton.snp.makeConstraints {
			$0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(myDevice.MyDiariesViewAddDiaryButtonPadding)
		}
		
		let image = UIImage(
			systemName: "person.circle",
			withConfiguration: UIImage.SymbolConfiguration(pointSize: 35)
		)?.withTintColor(UIColor.sandbrownColor, renderingMode: .alwaysOriginal)
		profileButton.setupViews(image)
		profileButton.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(25)
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
	}
	
	private func bind() {
		collectionView.bind(viewModel.diaryCollectionViewModel)
		collectionView.rx
			.modelSelected(Diary.self)
			.subscribe(onNext: { diary in
				let vc = MyDiaryPagesViewController(diaryData: diary)
				self.navigationController?.pushViewController(vc, animated: true)
			})
			.disposed(by: disposeBag)
		
		addDiaryButton.rx.tap
			.bind {
				self.addDiaryButton.setImage(UIImage(named: "closeButton"), for: .normal)
				let popUp = PopUpViewController(popUpPosition: .bottom)
				popUp.addButton(buttonTitle: "다이어리 추가", action: self.createButtonTapped)
				popUp.addButton(buttonTitle: "초대코드로 참가", action: self.joinButtonTapped)
				self.present(popUp, animated: false)
			}
			.disposed(by: disposeBag)
      
		profileButton.rx.tap
			.bind {
				let vc = MyPageViewController()
				self.navigationController?.pushViewController(vc, animated: true)
			}
			.disposed(by: disposeBag)
	}
	
	private func setupNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadDiaryCell), name: .reloadDiary, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeAddButtonImage), name: .changeAddButtonImage, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(mapListHalfModal(notification:)), name: .mapAnnotationTapped, object: nil)
	}
	
	private func isIndicator() {
		if viewModel.isInitializing {
			self.view.isUserInteractionEnabled = false
		} else {
			self.view.isUserInteractionEnabled = true
		}
	}
	
	@objc private func reloadDiaryCell() {
		viewModel.createCell()
	}
	
	@objc private func changeAddButtonImage() {
		addDiaryButton.setImage(UIImage(named: "plusButton"), for: .normal)
	}

	@objc private func mapListHalfModal(notification: NSNotification) {
		guard let day = notification.userInfo?["day"] as? Int else {
			return
		}
		
		guard let selectedLocation = notification.userInfo?["selectedLocation"] as? Location else {
			return
		}
		
		let vc = MapListViewController(viewMdoel: viewModel.mapViewModel, day: day, selectedLocation: selectedLocation)
		let titles = viewModel.mapViewModel.mapData
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
	
	@objc func createButtonTapped() {
        let vc = DiaryConfigViewController()
        vc.bind(DiaryConfigViewModel(diary: nil))
		vc.modalPresentationStyle = .fullScreen
		self.present(vc, animated: true, completion: nil)
	}
	
	@objc func joinButtonTapped() {
		let joinDiaryAlert = UIAlertController(title: "초대코드 입력", message: "받은 초대코드를 입력해주세요.", preferredStyle: .alert)
		let joinAction = UIAlertAction(title: "확인", style: .default) { action in
			if let textField = joinDiaryAlert.textFields?.first {
				self.viewModel.isDiaryCodeEqualTo(textField.text ?? "")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+0.5) {
					if self.viewModel.isEqual {
						self.viewModel.updateJoinDiary(textField.text ?? "")
						self.reloadDiaryCell()
						self.view.showToastMessage("다이어리가 추가되었습니다.")
					} else {
						self.view.showToastMessage("잘못된 초대코드입니다.")
					}
				}
				self.dismiss(animated: true, completion: nil)
			}
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel) { action in
			self.dismiss(animated: true, completion: nil)
		}
		joinDiaryAlert.addTextField()
		joinDiaryAlert.addAction(joinAction)
		joinDiaryAlert.addAction(cancelAction)
		self.present(joinDiaryAlert, animated: true)
	}
}

extension MyHomeViewController: UISheetPresentationControllerDelegate {
	@available(iOS 15.0, *)
	func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheetPresentationController: UISheetPresentationController) {
		print(sheetPresentationController.selectedDetentIdentifier == .large ? "large" : "medium")
	}
}

extension MyHomeViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		MapHalfModalPresentationController(presentedViewController: presented, presenting: presenting)
	}
}
