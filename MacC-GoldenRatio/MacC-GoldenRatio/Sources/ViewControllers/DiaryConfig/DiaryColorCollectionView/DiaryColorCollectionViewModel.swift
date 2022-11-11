//
//  DiaryColorCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/07.
//

import RxSwift
import RxCocoa

struct DiaryColorCollectionViewModel {
    let colors = ["Red", "Orange", "Yellow", "Green", "Blue", "Purple", "Pink", "Brown", "Black", "White"]
    let diaryColorCellViewModel = DiaryColorCellViewModel()
    private let disposeBag = DisposeBag()
    
    // ViewModel -> View
    var cellData = BehaviorSubject<[Bool]>.init(value: [Bool](repeating: false, count: 10))
    
    // View -> ViewModel
    var itemSelected = PublishSubject<Int>()
    
    init() {
        // TODO: 다이어리 수정의 경우 itemSelected를 초기에 담고 있어야 함 (diaryColor -> index추출 -> itemSelected)
        
        // 셀의 선택 여부 상태 전달
        itemSelected
            .subscribe(onNext: { index in
                var states = [Bool](repeating: false, count: 10)
                states[index] = true
                print(states)
            })
            .disposed(by: disposeBag)

        // itemSelected.accept(initial)
    }
    
}
