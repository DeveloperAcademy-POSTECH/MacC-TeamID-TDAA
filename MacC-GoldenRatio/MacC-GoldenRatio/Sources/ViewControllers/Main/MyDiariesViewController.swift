//
//  MyDiariesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import SnapKit
import UIKit

final class MyDiariesViewController: UIViewController {
	private let viewModel = MyDiariesViewModel()
	private let myDevice = UIScreen.getDevice()
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
    }
	
	private func setupSubViews() {
		[diaryCollectionView, addDiaryButton].forEach { view.addSubview($0) }
		
		diaryCollectionView.snp.makeConstraints {
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
		if viewModel.shouldLoadDiaryResult.count == 0 {
			let label = UILabel()
			label.text = "다이어리를 추가해주세요."
			label.textAlignment = .center
			collectionView.backgroundView = label
		} else {
			collectionView.backgroundView = nil
		}
		
		return viewModel.shouldLoadDiaryResult.count
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell
		
		var imageViews = [UIImageView]()
		
		// TODO: ViewModel 작업 후 수정 예정
		for _ in 0..<viewModel.shouldLoadDiaryResult[indexPath.item].userUIDs.count {
			let imageView = UIImageView(image: UIImage(systemName: "person"))
			imageView.contentMode = .scaleToFill
			imageView.clipsToBounds = true
			imageView.layer.cornerRadius = 12.5
			imageView.layer.borderWidth = 0.2
			imageView.layer.borderColor = UIColor.gray.cgColor
			imageView.backgroundColor = .white
			imageViews.append(imageView)
		}
		
		cell?.setup(title: viewModel.shouldLoadDiaryResult[indexPath.item].diaryName, imageViews: imageViews)

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
		return CGSize(width: myDevice.diaryCollectionViewCellWidth, height: UIScreen.getDevice().diaryCollectionViewCellHeight)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
		CGSize(width: collectionView.frame.width - myDevice.diaryCollectionViewCellHeaderWidthPadding, height: myDevice.diaryCollectionViewCellHeaderHeight+myDevice.diaryCollectionViewCellHeaderTop)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets(top: myDevice.diaryCollectionViewCellTop, left: myDevice.diaryCollectionViewCellLeading, bottom: myDevice.diaryCollectionViewCellBottom, right: myDevice.diaryCollectionViewCellTrailing)
	}
}
