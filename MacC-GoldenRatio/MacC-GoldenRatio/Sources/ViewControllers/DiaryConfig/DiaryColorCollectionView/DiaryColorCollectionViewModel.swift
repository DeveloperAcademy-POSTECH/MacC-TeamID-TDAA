//
//  DiaryColorCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/07.
//

import RxSwift
import RxCocoa

struct DiaryColorCollectionViewModel {
    let colors: [String] = ["diaryRed", "diaryOrange", "diaryYellow", "diaryGreen", "diaryBlue", "diaryPurple", "diaryPink", "diaryBrown", "diaryBlack", "diaryWhite"]
    var diaryColorCellViewModel = DiaryColorCellViewModel()
    private let disposeBag = DisposeBag()
    
    // ViewModel -> View
    var cellData: Observable<[Bool]>
    
    // View -> ViewModel
    var itemSelected = PublishSubject<Int>()
    
    init() {
        itemSelected
            .subscribe(onNext: { index in
                var states = [Bool](repeating: false, count: 10)
                states[index] = true
            })
            .disposed(by: disposeBag)
        
        cellData = itemSelected
            .map { index in
                print(index)
                var states = [Bool](repeating: false, count: 10)
                states[index] = true
                return states
            }
            .startWith([Bool](repeating: false, count: 10))
    }
}
