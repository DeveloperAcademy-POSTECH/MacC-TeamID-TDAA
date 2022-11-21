//
//  DiaryCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/29.
//

import RxCocoa
import RxSwift

struct DiaryCollectionViewModel {
	let collectionDiaryData = BehaviorRelay<[Diary]>(value: [])
}
