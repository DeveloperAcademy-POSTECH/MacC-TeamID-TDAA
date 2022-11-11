//
//  DiaryCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/30.
//

import RxCocoa
import RxDataSources
import RxSwift
import UIKit

class DiaryCollectionView: UICollectionView {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	
	private var source: RxCollectionViewSectionedReloadDataSource<DiarySection>!
	
	override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		let layout = UICollectionViewFlowLayout()
		super.init(frame: frame, collectionViewLayout: layout)
		self.collectionViewLayout = layout
		self.showsVerticalScrollIndicator = false
		self.backgroundColor = UIColor.clear
		self.register(DiaryCollectionViewCell.self, forCellWithReuseIdentifier: "DiaryCollectionViewCell")
		self.register(DiaryCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "DiaryCollectionHeaderView")
		self.rx.setDelegate(self)
			.disposed(by: disposeBag)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	func bind(_ viewModel: DiaryCollectionViewModel) {
		configureCollectionViewDataSource()
		viewModel.collectionDiaryData
			.bind(to: self.rx.items(dataSource: source))
			.disposed(by: disposeBag)
		
		viewModel.collectionDiaryData
			.subscribe(onNext: { data in
				DispatchQueue.main.async {
					if data.first?.items.count == 0 {
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
	
	private func configureCollectionViewDataSource() {
		source = RxCollectionViewSectionedReloadDataSource<DiarySection>(configureCell: { dataSource, collectionView, indexPath, item in
			if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "DiaryCollectionViewCell", for: indexPath) as? DiaryCollectionViewCell {
				cell.setup(cellData: DiaryCell(diaryUUID: item.diaryUUID, diaryName: item.diaryName, diaryCover: item.diaryCover))
				return cell
			} else {
				return UICollectionViewCell()
			}
		}, configureSupplementaryView: { (dataSource, collectionView, kind, indexPath) -> UICollectionReusableView in
			switch kind {
			case UICollectionView.elementKindSectionHeader:
				if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DiaryCollectionHeaderView", for: indexPath) as? DiaryCollectionHeaderView {
					return header
				} else {
					return UICollectionReusableView()
				}
			default:
				fatalError()
			}
		})
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
