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
                        dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: UIImage(named: "diaryDaysDefault")!))
                    }
                })
                .disposed(by: disposeBag)
        }
        
        self.cellData.onNext(dataForCellData)
    }
    
    func arrayToDays(model: MyDiaryDaysModel) -> [DiaryDayModel] {
        let days = model.diary.diaryPages.count
        var dataForCellData: [DiaryDayModel] = []
        
        for day in 1...days {
            // Model -> ViewModel
            model.fetchImage(day: day)
                .subscribe(onNext: {
                    let dayLabelData = "\(day)일차"
                    let dateLabelData = model.makeDateString(day: day)
                    let imageData: UIImage? = $0
                    
                    if let imageData = imageData {
                        dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: imageData))
                    } else {
                        dataForCellData.append(DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: UIImage(named: "diaryDaysDefault")!))
                    }
                    
                })
                .disposed(by: self.disposeBag)
        }
        return dataForCellData
    }

}


