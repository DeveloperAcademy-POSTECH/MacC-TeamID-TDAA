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
            model.fetchImage(day: day)
                .observe(on: MainScheduler.instance)
                .subscribe(onNext: {
                    let dayLabelData = "\(day)일차"
                    let dateLabelData = model.makeDateString(day: day)
                    let imageData: UIImage? = $0
                    
                    if let imageData = imageData {
                        dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: imageData))
                    } else {
                        // TODO: 디폴트 이미지 사용 예정
                        dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: UIImage(named: "manLong")!))
                    }
                    
                })
                .disposed(by: disposeBag)
        }
        
        self.cellData = Observable<[DiaryDayModel]>.just(dataForCellData)
    }
}
