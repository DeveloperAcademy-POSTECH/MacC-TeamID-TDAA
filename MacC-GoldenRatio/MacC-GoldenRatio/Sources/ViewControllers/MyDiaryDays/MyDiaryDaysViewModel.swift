//
//  MyDiaryDaysViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxCocoa
import RxSwift

class MyDiaryDaysViewModel {
    let disposeBag = DisposeBag()
    
    var myDiaryDaysModel: MyDiaryDaysModel
    var diarydaysCollectionViewModel: DiaryDaysCollectionViewModel
    let albumCollectionViewModel = AlbumCollectionViewModel()
    let mapViewModel = MapViewModel()
    
    let segmentIndex = BehaviorRelay<Int>(value: 0)
    let selectedViewType: Driver<[Bool]>
    
    init(diary: Diary) {
        self.myDiaryDaysModel = MyDiaryDaysModel(diary: diary)
        self.diarydaysCollectionViewModel = DiaryDaysCollectionViewModel(model: myDiaryDaysModel)
        
        self.selectedViewType = segmentIndex
            .map{ isHidden in
                var array = [Bool](repeating: true, count: 3)
                array[isHidden] = false
                return array
            }
            .asDriver(onErrorJustReturn: [Bool](repeating: false, count: 3))
        
        self.albumCollectionViewModel.collectionDiaryData.onNext(diary)
        
        self.mapViewModel.mapDiaryData.onNext(diary)
    }
    
    
//    func updateModel() {
//        Task {
//            try await self.myDiaryDaysModel.updateDiaryData()
//                .subscribe(onNext: {
//                    self.myDiaryDaysModel = MyDiaryDaysModel(diary: $0)
//                    let daysModel = self.diarydaysCollectionViewModel.arrayToDays(model: self.myDiaryDaysModel)
//                    self.diarydaysCollectionViewModel.cellData.onNext(daysModel)
//                    self.albumCollectionViewModel.collectionDiaryData.onNext($0)
//                    self.mapViewModel.mapDiaryData.onNext($0)
//                })
//                .disposed(by: disposeBag)
//        }
//    }
}
