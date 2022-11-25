//
//  ThumbnailConfigViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/24.
//

import RxSwift
import RxCocoa
import UIKit

struct ThumbnailConfigViewModel {
    private let disposeBag = DisposeBag()
    
    let previewViewModel: ThumbnailPreviewViewModel
    let dayAlbumViewModel = AlbumCollectionViewModel()
    
    // ViewModel -> View
    let dismiss: Driver<Void>
    let complete: Driver<Void>
    // let previewData = PublishRelay<DiaryDayModel>()
    
    // View -> ViewModel
    let doneButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    
    init(diary: Diary, selectedDay: Int) {
        let diaryModel = MyDiaryDaysModel(diary: diary)
        self.previewViewModel = ThumbnailPreviewViewModel(model: diaryModel, selectedDay: selectedDay)
        self.dayAlbumViewModel.collectionDiaryDataWithDay.onNext((diary, selectedDay))
        
        self.dismiss = cancelButtonTapped
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: .empty())
        
        self.complete = doneButtonTapped
            .map { _ in
                print("\(selectedDay)일차 다이어리 저장") // 썀네일 데이터 업데이트
                return Void()
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
