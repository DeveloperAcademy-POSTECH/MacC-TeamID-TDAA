//
//  DiaryDaysCellViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxCocoa
import RxSwift
import UIKit

struct DiaryDaysCellViewModel {
    
    // ViewModel -> View
    let isSelected: Signal<Void>
    
    // View -> ViewModel
    let rowSelect = PublishRelay<Int>()
    
    init() {
        self.isSelected = rowSelect
            .map { selectIndex in Void() }
            .asSignal(onErrorJustReturn: Void())
    }
}
