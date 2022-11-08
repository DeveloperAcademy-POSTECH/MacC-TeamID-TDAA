//
//  DiaryColorCellViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/07.
//

import RxCocoa

struct DiaryColorCellViewModel {
    
    // ViewModel -> View
    let isSelected: Signal<Bool>
    let colorSelect = PublishRelay<Bool>()
    
    init() {
        self.isSelected = colorSelect
            .asSignal(onErrorJustReturn: false)
    }
}
