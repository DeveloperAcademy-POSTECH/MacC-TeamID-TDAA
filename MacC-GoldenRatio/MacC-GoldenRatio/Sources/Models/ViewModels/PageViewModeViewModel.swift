//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import RxDataSources
import RxSwift
import UIKit

class PageViewModeViewModel {
    
    var disposeBag = DisposeBag()
    
    var diaryObservable: BehaviorSubject<Diary>!
    var selectedPageIndexSubject: BehaviorSubject<(Int,Int)>! // n 일차에 m 번째 페이지.
    
    var allPageObservable: Observable<[[Page]]>!
    var pageCollectionViewData: Observable<[PageSection]>!
    var pageCollectionViewCurrentCellIndex: Observable<IndexPath>!
    var pageIndexDescriptionObservable: Observable<String>!

    init(diary: Diary, selectedDayIndex: Int) {
        self.diaryObservable = BehaviorSubject(value: diary)
        self.selectedPageIndexSubject = BehaviorSubject(value: (selectedDayIndex,0))
        
        self.allPageObservable = setAllPageObservable()
        self.pageCollectionViewData = setPageCollectionViewData()
        self.pageCollectionViewCurrentCellIndex = setPageCollectionViewCurrentCellIndex()
        self.pageIndexDescriptionObservable = setPageIndexDescriptionObservable()
    }

    func setAllPageObservable() -> Observable<[[Page]]> {
        self.diaryObservable
            .observe(on: MainScheduler.instance)
            .map {
                var returnVal: [[Page]] = []
                $0.diaryPages.forEach { _ in 
                    returnVal.append([])
                }
                $0.diaryPages.enumerated().forEach { (pagesIndex, pages) in
                    returnVal[pagesIndex].append(contentsOf: pages.pages)
                }
                return returnVal
            }
    }
    
    func setPageCollectionViewData() -> Observable<[PageSection]> {
        self.allPageObservable
            .observe(on: MainScheduler.instance)
            .map {
                $0.map {
                    PageSection(header: "", items: $0)
                }
            }
    }
    
    func setPageCollectionViewCurrentCellIndex()-> Observable<IndexPath> {
        return selectedPageIndexSubject
                .map {(selectedPageIndex) in
                    return IndexPath(item: selectedPageIndex.0, section: selectedPageIndex.1)
                }
    }
    
    func setPageIndexDescriptionObservable() -> Observable<String> {
        return Observable.combineLatest(diaryObservable, selectedPageIndexSubject)
            .map { (diary, selectedPageIndex) in
                let pagesCount = diary.diaryPages[selectedPageIndex.0].pages.count
                return (selectedPageIndex.1 + 1).description + "/" + pagesCount.description
            }
    }
}
