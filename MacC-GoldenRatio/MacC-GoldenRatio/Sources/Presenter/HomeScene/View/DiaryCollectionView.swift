//
//  DiaryCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/30.
//

import RxCocoa
import RxSwift
import UIKit

class DiaryCollectionView: UICollectionView {
	private let disposeBag = DisposeBag()
	
	let viewModel: DiaryCollectionViewModel
	
	init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout, viewModel: DiaryCollectionViewModel) {
		let layout = UICollectionViewFlowLayout()
		self.viewModel = viewModel
		super.init(frame: frame, collectionViewLayout: layout)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind() {
		viewModel.collectionDiaryData
			.bind(to: self.rx.items(cellIdentifier: "DiaryCollectionViewCell", cellType: DiaryCollectionViewCell.self)) { index, data, cell in
				let cellData = DiaryCell(diaryUUID: data.diaryUUID, diaryName: data.diaryName, diaryLocation: data.diaryLocation, diaryStartDate: data.diaryStartDate, diaryEndDate: data.diaryEndDate, diaryCover: data.diaryCover, diaryCoverImage: data.diaryCoverImage, userUIDs: data.userUIDs)
				cell.bind(viewModel: self.viewModel)
				cell.setup(cellData: cellData)
				cell.removeButton.diaryCell = cellData
				
				self.viewModel.longPressedEnabled.value ? cell.startAnimate() : cell.stopAnimate()
			}
			.disposed(by: disposeBag)
		
		viewModel.collectionDiaryData
			.subscribe(onNext: { data in
				DispatchQueue.main.async {
					if data.count == 0 {
						let emptyView = CollectionEmptyView()
						emptyView.setupViews(text: "다이어리를 추가해주세요.")
						self.backgroundView = emptyView
					} else {
						self.backgroundView = nil
					}
				}
			})
			.disposed(by: disposeBag)
	}
}

extension DiaryCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return Layout.diaryCollectionViewCellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}
