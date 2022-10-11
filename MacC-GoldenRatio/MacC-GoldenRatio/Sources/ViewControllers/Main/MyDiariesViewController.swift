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

final class MyDiariesViewController: UIViewController {
	private var cancelBag = Set<AnyCancellable>()
	private let viewModel = MyDiariesViewModel(userUid: Auth.auth().currentUser?.uid ?? "")
	private let myDevice = UIScreen.getDevice()
	private var myDiariesViewModalBackgroundView = UIView()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)

		collectionView.delegate = self
		collectionView.dataSource = self

		collectionView.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
		collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		collectionView.register(DiaryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DiaryCollectionHeaderView")

		return collectionView
	}()
	
	private lazy var addDiaryButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "plus.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: UIScreen.getDevice().MyDiariesViewAddDiaryButtonSize))?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
		button.addTarget(self, action: #selector(addDiaryButtonTapped), for: .touchUpInside)
		
		return button
	}()
	
	private var createDiaryButton: UIButton = {
		let button = UIButton()
		button.setTitle("다이어리 생성", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(MyDiariesViewCustomModalVC.createDiaryButtonTapped), for: .touchUpInside)
		
		button.snp.makeConstraints {
			$0.height.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewButtonHeight)
		}
		
		return button
	}()
	
	private var joinDiaryButton: UIButton = {
		let button = UIButton()
		button.setTitle("초대코드로 참가", for: .normal)
		button.setTitleColor(UIColor.black, for: .normal)
		button.addTarget(self, action: #selector(MyDiariesViewCustomModalVC.joinDiaryButtonTapped), for: .touchUpInside)
		
		button.snp.makeConstraints {
			$0.height.equalTo(UIScreen.getDevice().MyDiariesViewCustomModalViewButtonHeight)
		}
		
		return button
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		setupSubViews()
		setupViewModel()
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
	
	private func addMenuView() {
		view.addSubview(myDiariesViewModalBackgroundView)
		myDiariesViewModalBackgroundView.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
		
		DispatchQueue.main.async { [weak self] in
			self?.myDiariesViewModalBackgroundView.backgroundColor = .black
			self?.myDiariesViewModalBackgroundView.alpha = 0.1
		}
	}
	
	private func removeMenuView() {
		DispatchQueue.main.async { [weak self] in
			self?.myDiariesViewModalBackgroundView.removeFromSuperview()
		}
	}
	
	@objc private func addDiaryButtonTapped() {
		let CustomMenuModalVC = MyDiariesViewCustomModalVC.instance()
		CustomMenuModalVC.delegate = self
		addMenuView()
		CustomMenuModalVC.stackView.addArrangedSubview(createDiaryButton)
		CustomMenuModalVC.stackView.addArrangedSubview(joinDiaryButton)
		CustomMenuModalVC.stackViewBottom = myDevice.MyDiariesViewCustomModalViewStackBottom
		CustomMenuModalVC.stackViewTrailing = myDevice.MyDiariesViewCustomModalViewStackTrailing
		CustomMenuModalVC.stackViewSize = CGSize(width: myDevice.MyDiariesViewCustomModalViewStackWidth, height: myDevice.MyDiariesViewCustomModalViewButtonHeight*CustomMenuModalVC.stackView.arrangedSubviews.count)
		present(CustomMenuModalVC, animated: true, completion: nil)
	}
}

extension MyDiariesViewController: MyDiariesViewCustomModalDelegate {
	func createDiaryButtonTapped() {
		self.removeMenuView()
	}
	
	func joinDiaryButtonTapped() {
		self.removeMenuView()
	}
	
	func tapGestureHandler() {
		self.removeMenuView()
	}
}

extension MyDiariesViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		// TODO: ViewModel 작업 후 수정 예정
		if viewModel.diaryCellData.isEmpty {
			let label = UILabel()
			label.text = "다이어리를 추가해주세요."
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

extension MyDiariesViewController: UICollectionViewDelegate {
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		// TODO: 다이어리 화면 완료시 작업 예정
	}
}

extension MyDiariesViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return myDevice.diaryCollectionViewCellSize
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		CGSize(width: collectionView.frame.width - myDevice.diaryCollectionViewCellHeaderWidthPadding, height: myDevice.diaryCollectionViewCellHeaderHeight+myDevice.diaryCollectionViewCellHeaderTop)
	}

	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: myDevice.diaryCollectionViewCellTop, left: myDevice.diaryCollectionViewCellLeading, bottom: myDevice.diaryCollectionViewCellBottom, right: myDevice.diaryCollectionViewCellTrailing)
	}
}

private extension MyDiariesViewController {
	func setupViewModel() {
		viewModel.$diaryCellData
			.receive(on: DispatchQueue.main)
			.sink { [weak self] diaryCell in
				self?.collectionView.reloadData()
			}
			.store(in: &cancelBag)
	}
}
