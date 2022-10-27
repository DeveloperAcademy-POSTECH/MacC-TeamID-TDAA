//
//  MyDiariesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import Firebase
import FirebaseAuth
import SnapKit
import UIKit

final class MyHomeViewController: UIViewController {
	private var cancelBag = Set<AnyCancellable>()
	private let viewModel = MyHomeViewModel()
	private let myDevice = UIScreen.getDevice()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		
		collectionView.delegate = self
		collectionView.dataSource = self

		collectionView.backgroundColor = UIColor.clear
		collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		collectionView.register(DiaryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DiaryCollectionHeaderView")

		return collectionView
	}()
	
	private lazy var addDiaryButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(named: "plusButton"), for: .normal)
		button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
		
		return button
	}()
	
    override func viewDidLoad() {
        super.viewDidLoad()
		setupSubViews()
		setupViewModel()
		setupNotification()
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		viewModel.isInitializing = false
	}
	
	private func setupSubViews() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
		
		[collectionView, addDiaryButton].forEach { view.addSubview($0) }

		collectionView.snp.makeConstraints {
			$0.edges.equalTo(view.safeAreaLayoutGuide)
		}
		addDiaryButton.snp.makeConstraints {
			$0.bottom.trailing.equalTo(view.safeAreaLayoutGuide).inset(myDevice.MyDiariesViewAddDiaryButtonPadding)
		}
	}
	
	private func setupNotification() {
		NotificationCenter.default.addObserver(self, selector: #selector(reloadDiaryCell), name: .reloadDiary, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(changeAddButtonImage), name: .changeAddButtonImage, object: nil)
	}
	
	private func isIndicator() {
		if viewModel.isInitializing {
			self.view.isUserInteractionEnabled = false
		} else {
			self.view.isUserInteractionEnabled = true
		}
	}
	
	@objc private func reloadDiaryCell() {
		viewModel.fetchLoadData()
	}
	
	@objc private func changeAddButtonImage() {
		addDiaryButton.setImage(UIImage(named: "plusButton"), for: .normal)
	}
	
	@objc private func menuButtonTapped() {
		addDiaryButton.setImage(UIImage(named: "closeButton"), for: .normal)
		let popUp = PopUpViewController(popUpPosition: .bottom)
		popUp.addButton(buttonTitle: "다이어리 추가", action: createButtonTapped)
		popUp.addButton(buttonTitle: "초대코드로 참가", action: joinButtonTapped)
		present(popUp, animated: false)
	}
	
	@objc func createButtonTapped() {
		let vc = DiaryConfigViewController(mode: .create, diary: nil)
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
						self.viewModel.fetchLoadData()
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

extension MyHomeViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if !viewModel.isInitializing && viewModel.diaryCellData.isEmpty {
			let label = UILabel()
			label.text = "다이어리를 추가해주세요."
			label.font = myDevice.collectionBackgoundViewFont
            label.textColor = UIColor(named: "calendarWeeklyGrayColor")
			label.textAlignment = .center
			collectionView.backgroundView = label
		} else {
			collectionView.backgroundView = nil
		}

		return viewModel.diaryCellData.count
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell
		cell?.setup(cellData: viewModel.diaryCellData[indexPath.item])
		return cell ?? UICollectionViewCell()
	}

	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		guard kind == UICollectionView.elementKindSectionHeader,
			  let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DiaryCollectionHeaderView", for: indexPath) as? DiaryCollectionHeaderView
		else {
			return UICollectionReusableView()
		}

		header.setupViews()

		return header
	}
}

extension MyHomeViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let vc = MyDiaryPagesViewController(diaryData: viewModel.diaryData[indexPath.item])
		self.navigationController?.pushViewController(vc, animated: true)
	}
}

extension MyHomeViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return myDevice.diaryCollectionViewCellSize
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		CGSize(width: collectionView.frame.width - myDevice.diaryCollectionViewCellHeaderWidthPadding, height: myDevice.diaryCollectionViewCellHeaderHeight+myDevice.diaryCollectionViewCellHeaderTop)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: myDevice.diaryCollectionViewCellTop, left: myDevice.diaryCollectionViewCellLeading, bottom: myDevice.diaryCollectionViewCellBottom, right: myDevice.diaryCollectionViewCellTrailing)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return CGFloat(UIScreen.getDevice().diaryCollectionViewCellTop)
	}
}

private extension MyHomeViewController {
	func setupViewModel() {
		viewModel.fetchLoadData()
		viewModel.$diaryCellData
			.receive(on: DispatchQueue.main)
			.sink { [weak self] diaryCell in
				self?.collectionView.reloadData()
				self?.isIndicator()
			}
			.store(in: &cancelBag)
	}
}
