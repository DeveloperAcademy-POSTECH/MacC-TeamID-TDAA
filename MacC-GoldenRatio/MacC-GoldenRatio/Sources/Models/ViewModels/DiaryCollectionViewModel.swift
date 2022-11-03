//
//  DiaryCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/29.
//

import RxCocoa
import RxSwift

struct DiaryCollectionViewModel {
	let collectionDiaryData = PublishSubject<[Diary]>()
	let diaryData: Driver<[Diary]>
	
	var isInitializing = true {
		didSet {
			if isInitializing {
				LoadingIndicator.showLoading(loadingText: "다이어리를 불러오는 중입니다.")
			} else {
				LoadingIndicator.hideLoading()
			}
		}
	}
	
	init() {
		self.diaryData = collectionDiaryData
			.asDriver(onErrorJustReturn: [])
	}
}
