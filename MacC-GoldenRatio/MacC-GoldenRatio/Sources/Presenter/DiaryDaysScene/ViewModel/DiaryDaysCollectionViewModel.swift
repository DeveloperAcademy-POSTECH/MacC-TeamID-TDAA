//
//  DiaryDaysCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxCocoa
import RxSwift
import UIKit

struct DiaryDaysCollectionViewModel {
    let disposeBag = DisposeBag()
    
    // ViewModel -> View
    var cellData = PublishSubject<[DiaryDayModel]>()
    
    // View -> ViewModel
    let selectedDay = PublishRelay<Int>()
    
    init(model: MyDiaryDaysModel) {
        let dataForCellData = model.daysToArray(model: model)
        self.cellData.onNext(dataForCellData)
    }
}


