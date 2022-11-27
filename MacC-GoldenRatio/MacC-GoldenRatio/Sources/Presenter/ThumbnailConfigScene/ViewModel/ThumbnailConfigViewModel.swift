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
    private var completion: (Diary) -> Void
    
    let previewViewModel: ThumbnailPreviewViewModel
    let dayAlbumViewModel = AlbumCollectionViewModel()
    
    // ViewModel -> View
    let dismiss: Driver<Void>
    let complete: Driver<Void>
    
    // View -> ViewModel
    let doneButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    let selectedIndex = PublishRelay<Int>()
    
    init(diary: Diary, selectedDay: Int, completion: @escaping (Diary) -> Void) {
        self.completion = completion
        
        let diaryModel = MyDiaryDaysModel(diary: diary)
        let imageURLs = self.dayAlbumViewModel.convertDiaryToAlbumDataWithDay(diary, selectedDay: selectedDay).imageURLs
        var imageURL: String?
        
        self.previewViewModel = ThumbnailPreviewViewModel(model: diaryModel, selectedDay: selectedDay)
        self.dayAlbumViewModel.collectionDiaryDataWithDay.onNext((diary, selectedDay))
        
        self.dismiss = cancelButtonTapped
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: .empty())
        
        self.selectedIndex
            .subscribe(onNext: { index in
                imageURL = imageURLs?[index]
            })
            .disposed(by: disposeBag)
        
        self.complete = doneButtonTapped
            .map { _ in
                guard let imageURL = imageURL else { return }
                diaryModel.updateTumbnail(urlString: imageURL, selectedDay: selectedDay, completion: { newDiary in
                    NotificationCenter.default.post(name: .reloadDiary, object: nil)
                    completion(newDiary)
                })
                return Void()
            }
            .asDriver(onErrorDriveWith: .empty())
    }
}
