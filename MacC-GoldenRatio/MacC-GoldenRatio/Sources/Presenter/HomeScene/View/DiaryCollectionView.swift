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
	private let myDevice = UIScreen.getDevice()
	
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
				cell.setup(cellData: cellData)
				
				cell.removeButton.addTarget(self, action: #selector(self.removeButtonTapped), for: .touchUpInside)
				cell.removeButton.diaryCell = cellData
				
				if self.viewModel.longPressedEnabled.value {
					cell.startAnimate()
				}else{
					cell.stopAnimate()
				}
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
	
	@objc func removeButtonTapped(sender: RemoveButton) {
		if sender.diaryCell != nil {
			Observable.just(sender.diaryCell)
				.bind(to: self.viewModel.removeData)
				.disposed(by: disposeBag)
		}
	}
}

extension DiaryCollectionView: UICollectionViewDelegateFlowLayout {
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		return myDevice.diaryCollectionViewCellSize
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 10
	}
}
