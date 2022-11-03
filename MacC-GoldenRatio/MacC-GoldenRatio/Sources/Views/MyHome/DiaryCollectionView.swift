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
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: frame, collectionViewLayout: layout)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: DiaryCollectionViewModel) {
		viewModel.diaryData
			.asDriver(onErrorJustReturn: [])
			.drive(self.rx.items(cellIdentifier: "DiaryCollectionViewCell", cellType: DiaryCollectionViewCell.self)) { index, diary, cell in
				cell.setup(cellData: DiaryCell(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, diaryCover: diary.diaryCover))
			}
			.disposed(by: disposeBag)
		
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
	}
}

extension DiaryCollectionView: UICollectionViewDelegateFlowLayout {
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
