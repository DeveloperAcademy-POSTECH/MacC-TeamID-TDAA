//
//  AlbumCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/08.
//

import RxCocoa
import RxSwift
import UIKit

class AlbumCollectionView: UICollectionView {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: frame, collectionViewLayout: layout)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(MyAlbumCollectionViewCell.self, forCellWithReuseIdentifier: "MyAlbumCollectionViewCell")
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: AlbumCollectionViewModel) {
		viewModel.collectionCellData
			.bind(to: self.rx.items(cellIdentifier: "MyAlbumCollectionViewCell", cellType: MyAlbumCollectionViewCell.self)) { index, data, cell in
				cell.setup(image: data)
			}
			.disposed(by: disposeBag)
		
		viewModel.collectionCellData
			.subscribe(onNext: { data in
				DispatchQueue.main.async {
					if data.count == 0 {
						let emptyView = CollectionEmptyView()
						emptyView.setupViews(text: "추가하신 사진이 없어요.")
						self.backgroundView = emptyView
					} else {
						self.backgroundView = nil
					}
				}
			})
			.disposed(by: disposeBag)
	}
}

extension AlbumCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let size = (self.bounds.width-2)/3
		return CGSize(width: size, height: size)
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 1
	}
}
