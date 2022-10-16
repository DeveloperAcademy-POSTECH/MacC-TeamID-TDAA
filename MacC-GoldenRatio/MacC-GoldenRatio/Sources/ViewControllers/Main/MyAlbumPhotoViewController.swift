//
//  MyAlbumPhotoViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import Combine
import Firebase
import FirebaseAuth
import SnapKit
import UIKit

final class MyAlbumPhotoViewController: UIViewController {
	private let myDevice = UIScreen.getDevice()
	let totalCount: Int
	let albumData: AlbumData
	
	private var previousOffset: CGFloat = 0
	var photoPage: Int {
		didSet {
			if photoPage > totalCount {
				photoPage = totalCount
			}
			self.titleLabel.text = "\(photoPage+1)/\(totalCount)"
		}
	}
	
	init(photoPage: Int, totalCount: Int, albumData: AlbumData) {
		self.photoPage = photoPage
		self.totalCount = totalCount
		self.albumData = albumData
		super.init(nibName: nil, bundle: nil)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 10
		layout.scrollDirection = .horizontal
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.showsVerticalScrollIndicator = false
		
		collectionView.delegate = self
		collectionView.dataSource = self
		
		collectionView.showsHorizontalScrollIndicator = false
		collectionView.backgroundColor = UIColor.clear
		collectionView.register(MyAlbumPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumPhotoCollectionViewCell")
		collectionView.decelerationRate = .fast
		collectionView.isPagingEnabled = false

		return collectionView
	}()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.font = myDevice.myAlbumPhotoPageLabelFont
		label.textColor = .black
		
		return label
	}()
	
	private lazy var backButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "xmark")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.imageEdgeInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
		button.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
		
		return button
	}()
	
	private lazy var menuButton: UIButton = {
		let button = UIButton()
		button.setImage(UIImage(systemName: "ellipsis")?.withTintColor(UIColor.black, renderingMode: .alwaysOriginal), for: .normal)
		button.imageView?.contentMode = .scaleAspectFit
		button.imageEdgeInsets = UIEdgeInsets(top: 22, left: 22, bottom: 22, right: 22)
		button.addTarget(self, action: #selector(menuButtonTapped), for: .touchUpInside)
		
		return button
	}()

	override func viewDidLoad() {
		super.viewDidLoad()
		setupSubViews()
		updatePageOffset()
	}
	
	private func setupSubViews() {
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
		
		[collectionView, backButton, menuButton, titleLabel].forEach { view.addSubview($0) }
		
		titleLabel.text = "\(photoPage+1)/\(totalCount)"
		titleLabel.snp.makeConstraints {
			$0.top.equalToSuperview()
			$0.centerX.equalToSuperview()
			$0.bottom.equalTo(view.safeAreaLayoutGuide).inset(670)
		}
		
		backButton.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
			$0.leading.equalToSuperview().inset(20)
		}
		
		menuButton.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(10)
			$0.trailing.equalToSuperview().inset(20)
		}

		collectionView.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).inset(20)
			$0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
		}
	}
	
	@objc private func backButtonTapped() {
		dismiss(animated: true)
	}
	
	@objc private func menuButtonTapped() {
		let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
		let downloadAction = UIAlertAction(title: "저장하기", style: .default) { (action) in
			UIImageWriteToSavedPhotosAlbum(self.albumData.images?[self.photoPage] ?? UIImage(), self, nil, nil)
			
		}
		let cancelAction = UIAlertAction(title: "취소", style: .cancel)
		alert.addAction(downloadAction)
		alert.addAction(cancelAction)
		self.present(alert, animated: true)
	}
	
	private func updatePageOffset() {
		let newXPoint = CGFloat(self.photoPage) * (self.view.bounds.width + 10)
		DispatchQueue.main.async {
			UIView.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.5, options: .allowUserInteraction, animations: {
				self.collectionView.setContentOffset(CGPoint(x: newXPoint, y: 0), animated: false)
			}, completion: nil)
		}
	}
}

extension MyAlbumPhotoViewController: UICollectionViewDataSource {
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return albumData.images?.count ?? 0
	}

	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MyAlbumPhotoCollectionViewCell", for: indexPath) as? MyAlbumPhotoCollectionViewCell {
			cell.setup(image: albumData.images?[indexPath.item] ?? UIImage())
			return cell
		}
		return UICollectionViewCell()
	}
}

extension MyAlbumPhotoViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.view.bounds.width, height: self.view.bounds.height)
	}
}

extension MyAlbumPhotoViewController: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let cellWidthIncludeSpacing = self.view.bounds.width + 10

		var offset = targetContentOffset.pointee
		let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludeSpacing
		let roundedIndex: CGFloat = round(index)
		
		photoPage = Int(roundedIndex)

		offset = CGPoint(x: roundedIndex * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
		targetContentOffset.pointee = offset
	}
}

