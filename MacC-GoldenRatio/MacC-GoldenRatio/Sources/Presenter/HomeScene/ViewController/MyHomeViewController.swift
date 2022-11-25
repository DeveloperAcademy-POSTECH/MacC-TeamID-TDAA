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
	private let viewModel = MyHomeViewModel()
	private let myDevice = UIScreen.getDevice()
	
	private var currentLongPressedCell: DiaryCollectionViewCell?
	
	private lazy var collectionHeaderView = DiaryCollectionHeaderView()
	private lazy var collectionView = DiaryCollectionView(frame: .zero, collectionViewLayout: UICollectionViewLayout(), viewModel: viewModel.diaryCollectionViewModel)
	private lazy var addDiaryButton = HomeButtonView()
	private lazy var profileButton = HomeButtonView()
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		setupSubViews()
		bind()
		setupNotification()
		setupGestureRecognizer()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupSubViews() {
		self.view.backgroundColor = UIColor(named: "appBackgroundColor") ?? UIColor.clear

		[collectionHeaderView, collectionView, addDiaryButton, profileButton].forEach { view.addSubview($0) }
		
		collectionHeaderView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.height.equalTo(25)
		}
		
		collectionView.snp.makeConstraints {
			$0.top.equalTo(collectionHeaderView.snp.bottom).offset(50)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
			$0.leading.equalTo(view.safeAreaLayoutGuide).inset(10)
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
		}
		
		addDiaryButton.setupViews(UIImage(named: "plusButton"))
		addDiaryButton.snp.makeConstraints {
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(myDevice.MyDiariesViewAddDiaryButtonPadding)
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(40)
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
					popUp.addButton(buttonTitle: " 다이어리 추가", buttonSymbol: "doc.badge.plus", buttonSize: 17, action: self.createButtonTapped)
					popUp.addButton(buttonTitle: " 초대코드 참가", buttonSymbol: "envelope.open", buttonSize: 15, action: self.joinButtonTapped)
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
		
		viewModel.diaryCollectionViewModel.removeData
			.bind { data in
				if data != nil {
					let ac = UIAlertController(title: "다이어리를 나가시겠습니까?", message: "다이어리를 나가면 공동편집을 할 수 없습니다.", preferredStyle: .alert)
					ac.addAction(UIAlertAction(title: "다이어리 나가기", style: .destructive) { _ in
						self.viewModel.diaryCollectionViewModel.outCurrentDiary(data!.diaryUUID, data!.userUIDs)
						NotificationCenter.default.post(name: .reloadDiary, object: nil)
					})
					ac.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
					self.present(ac, animated: true, completion: nil)
				}
			}
			.disposed(by: disposeBag)
	}
	
	private func setupNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadDiaryCell), name: .reloadDiary, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeAddButtonImage), name: .changeAddButtonImage, object: nil)
	}
	
	private func setupGestureRecognizer() {
		let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGesture))
		tapGesture.cancelsTouchesInView = false
		viewModel.longPressedEnabled
			.asObservable()
			.subscribe(onNext: { value in
				if value {
					tapGesture.cancelsTouchesInView = false
					self.view.addGestureRecognizer(tapGesture)
				} else {
					tapGesture.cancelsTouchesInView = true
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
		if gestureRecognizer.state == .ended {
			Observable.just(true)
				.bind(to: viewModel.longPressedEnabled)
				.disposed(by: disposeBag)
			viewModel.createCell()
		} else {
			return
		}
	}
	
	@objc private func reloadDiaryCell() {
		viewModel.createCell()
	}
	
	@objc private func changeAddButtonImage() {
		addDiaryButton.setImage(UIImage(named: "plusButton"), for: .normal)
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
						self.view.showToastMessage("초대코드가 잘못되었습니다.")
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

extension MyHomeViewController: UIViewControllerTransitioningDelegate {
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		MapHalfModalPresentationController(presentedViewController: presented, presenting: presenting)
	}
}
