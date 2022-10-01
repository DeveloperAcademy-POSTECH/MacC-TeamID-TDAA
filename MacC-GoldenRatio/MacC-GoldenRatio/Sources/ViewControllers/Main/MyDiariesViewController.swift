//
//  MyDiariesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import SnapKit
import UIKit

final class MyDiariesViewController: UIViewController {
	private let diary = [Diary(diaryUUID: "", diaryName: "🌊포항항", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [0.0]), diaryStartDate: Date(), diaryEndDate: Date(), diaryPages: [[Page(pageUUID: "", items: [Item(itemUUID: "", itemType: ItemType.text, contents: "", itemSize: [0.0], itemPosition: [0.0], itemAngle: 0.0)])]], userUIDs: [User(userUID: "", userName: "칼리", userImageURL: ""), User(userUID: "", userName: "드록바", userImageURL: ""), User(userUID: "", userName: "해츨링", userImageURL: ""), User(userUID: "", userName: "라우", userImageURL: ""), User(userUID: "", userName: "산", userImageURL: "")])]
	
	private var myDiariesViewModalBackgroundView = UIView()
	
	private lazy var diaryCollectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		collectionView.backgroundColor = .systemBackground
		collectionView.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		collectionView.register(DiaryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DiaryCollectionHeaderView")
		
		return collectionView
	}()
	
	lazy var createDiaryButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "plus.circle", withConfiguration: UIImage.SymbolConfiguration(pointSize: UIScreen.getDevice().MyDiariesViewCreateDiaryButtonSize))?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
		button.addTarget(self, action: #selector(createDiaryButtonTapped), for: .touchUpInside)
		
		return button
	}()

    override func viewDidLoad() {
        super.viewDidLoad()
		setupSubViews()
    }
	
	private func setupSubViews() {
		[diaryCollectionView, createDiaryButton].forEach { view.addSubview($0) }
		
		diaryCollectionView.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide)
			$0.bottom.equalTo(view.safeAreaLayoutGuide)
			$0.leading.equalTo(view.safeAreaLayoutGuide)
			$0.trailing.equalTo(view.safeAreaLayoutGuide)
		}
		
		createDiaryButton.snp.makeConstraints {
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(UIScreen.getDevice().MyDiariesViewCreateDiaryButtonPadding)
			$0.trailing.equalTo(view.safeAreaLayoutGuide).inset(UIScreen.getDevice().MyDiariesViewCreateDiaryButtonPadding)
		}
	}
	
	private func showJoinDiaryAlert() {
		let joinDiaryAlert = UIAlertController(title: "초대코드 입력", message: "받은 초대코드를 입력해주세요.", preferredStyle: .alert)
		let joinAction = UIAlertAction(title: "확인", style: .default) { action in
			if let textField = joinDiaryAlert.textFields?.first {
				// TODO: 초대 코드 복사 로직 추가 예정
				print(textField.text)
			}
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		joinDiaryAlert.addTextField()
		joinDiaryAlert.addAction(joinAction)
		joinDiaryAlert.addAction(cancelAction)
		self.present(joinDiaryAlert, animated: true)
	}
	
	private func addMenuView() {
		view.addSubview(myDiariesViewModalBackgroundView)
		myDiariesViewModalBackgroundView.snp.makeConstraints {
			$0.edges.equalTo(0)
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
	
	@objc func createDiaryButtonTapped() {
		let CustomMenuModalVC = MyDiariesViewCustomModalVC.instance()
		CustomMenuModalVC.delegate = self
		addMenuView()
		present(CustomMenuModalVC, animated: true, completion: nil)
	}
}

extension MyDiariesViewController: MyDiariesViewCustomModalDelegate {
	func tapGestureHandler() {
		self.removeMenuView()
	}
}

extension MyDiariesViewController: UICollectionViewDataSource {
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		if diary.count == 0 {
			let label = UILabel()
			label.text = "다이어리를 추가해주세요."
			label.textAlignment = .center
			collectionView.backgroundView = label
		}
		
		return diary.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell
		
		var imageViews = [UIImageView]()
		
		for _ in 0..<diary[0].userUIDs.count {
			let imageView = UIImageView(image: UIImage(systemName: "person"))
			imageView.contentMode = .scaleToFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = 12.5
			imageView.layer.borderWidth = 0.2
			imageView.layer.borderColor = UIColor.gray.cgColor
			imageView.backgroundColor = .white
			imageViews.append(imageView)
		}
		
		cell?.setup(title: diary[0].diaryName, imageViews: imageViews)

		cell?.layer.borderWidth = 0.5
		cell?.layer.cornerRadius = 20
		cell?.layer.maskedCorners = CACornerMask(arrayLiteral: .layerMaxXMinYCorner, .layerMaxXMaxYCorner)
		cell?.layer.borderColor = UIColor.gray.cgColor

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

extension MyDiariesViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: UIScreen.getDevice().diaryCollectionViewCellWidth, height: UIScreen.getDevice().diaryCollectionViewCellHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		CGSize(width: collectionView.frame.width - UIScreen.getDevice().diaryCollectionViewCellHeaderWidthPadding, height: UIScreen.getDevice().diaryCollectionViewCellHeaderHeight+UIScreen.getDevice().diaryCollectionViewCellHeaderHeightPadding)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: UIScreen.getDevice().diaryCollectionViewCellTopInset, left: UIScreen.getDevice().diaryCollectionViewCellLeadingInset, bottom: UIScreen.getDevice().diaryCollectionViewCellBottomInset, right: UIScreen.getDevice().diaryCollectionViewCellTrailingInset)
	}
}
