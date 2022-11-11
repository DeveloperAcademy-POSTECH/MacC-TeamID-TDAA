//
//  PhotoCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/08.
//

import RxCocoa
import RxSwift
import UIKit

class PhotoCollectionView: UICollectionView {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: frame, collectionViewLayout: layout)
		layout.minimumLineSpacing = 10
		layout.scrollDirection = .horizontal
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.showsHorizontalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(MyAlbumPhotoCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumPhotoCollectionViewCell")
		self.decelerationRate = .fast
		self.isPagingEnabled = false
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: AlbumCollectionViewModel) {
		viewModel.collectionCellData
			.bind(to: self.rx.items(cellIdentifier: "MyAlbumPhotoCollectionViewCell", cellType: MyAlbumPhotoCollectionViewCell.self)) { index, data, cell in
				cell.setup(image: data)
			}
			.disposed(by: disposeBag)
	}
}

extension PhotoCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return CGSize(width: self.bounds.width, height: self.bounds.height)
	}
}

extension PhotoCollectionView: UIScrollViewDelegate {
	func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		let cellWidthIncludeSpacing = self.bounds.width + 10

		var offset = targetContentOffset.pointee
		let index = (offset.x + scrollView.contentInset.left) / cellWidthIncludeSpacing
		let roundedIndex: CGFloat = round(index)
		
		NotificationCenter.default.post(name: .paging, object: nil, userInfo: ["data": Int(roundedIndex)])

		offset = CGPoint(x: roundedIndex * cellWidthIncludeSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
		targetContentOffset.pointee = offset
	}
}
