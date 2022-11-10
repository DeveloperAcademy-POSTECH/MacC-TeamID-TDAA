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
    let diaryDaysCellViewModel = DiaryDaysCellViewModel()
    private let disposeBag = DisposeBag()
    
    // ViewModel -> View
    let cellData: Observable<[DiaryDayModel]>
    
    // View -> ViewModel
    let selectedDay = PublishRelay<Int>()
    
    init(model: MyDiaryDaysModel) {
        
        let days = model.diary.diaryPages.count
        var dataForCellData: [DiaryDayModel] = []
        
        for day in 1...days {
            
            // Model -> ViewModel
            let dayLabelData = "\(day)일차"
            let dateLabelData = model.makeDateString(day: day)
            let imageData: UIImage? = UIImage(named: "manLong")
            
            dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: imageData))
        }
        
        self.cellData = Observable<[DiaryDayModel]>.just(dataForCellData)
    }
}
