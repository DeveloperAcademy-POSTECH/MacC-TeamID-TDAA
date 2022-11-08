//
//  DiaryConfigCellViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/03.
//

import RxSwift
import RxCocoa

class DiaryConfigCellViewModel {
    var diaryColorViewModel = DiaryColorCollectionViewModel()
    
    // ViewModel -> View
    let setContent: Driver<ConfigContentType>
    let resetContentLabel: Observable<ConfigContentType>
    
    let textFieldEndEditing: Signal<Void>
    let showChildView: Signal<Void>
    
    // View -> ViewModel
    let textFieldText = PublishRelay<String?>()
    let contentButtonTitle = PublishRelay<String?>()
    
    let contentButtonTapped = PublishRelay<Void>()
    let clearButtonTapped = PublishRelay<Void>()
    
    let diaryData = PublishRelay<Diary?>()
    
    var diary: Diary?
    let configContentType: ConfigContentType
    
    init(type configContetType: ConfigContentType) {
        self.setContent = Driver.just(configContetType)
        self.configContentType = configContetType
        
        self.resetContentLabel = clearButtonTapped
            .map { _ in configContetType }
        
        self.textFieldEndEditing = contentButtonTapped
            .asSignal(onErrorSignalWith: .empty())
        
        self.showChildView = contentButtonTapped
            .asSignal(onErrorSignalWith: .empty())
    }
}
