//
//  ThumbnailPreviewViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/24.
//

import RxSwift
import RxCocoa

struct ThumbnailPreviewViewModel {
    // ViewModel -> View
    let previewData: BehaviorRelay<DiaryDayModel>
    
    init(model: MyDiaryDaysModel, selectedDay: Int) {
        let dataForPreview = model.diaryToDayModel(model: model, selectedDay: selectedDay)
        self.previewData = BehaviorRelay<DiaryDayModel>(value: dataForPreview)
    }
}
