//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import RxSwift
import UIKit

class PageViewModel {
    
    enum AddPage {
        case nextToCurrentPage
        case nextToLastPage
    }
    
    var disposeBag = DisposeBag()
    
    var diaryObservable: BehaviorSubject<Diary>!
    var selectedPageIndex: BehaviorSubject<(Int,Int)>! // n 일차에 m 번째 페이지.
    
    // for ViewMode
    var allPageItemObservable: Observable<[String:[Item]]>! // 모든 일차, 모든 인덱스의 item들
    var maxPageIndexByDayObservable: Observable<[Int]>! // 일차 별 최대 페이지 인덱스
    var allPageItemKeys: Observable<[String]>! // allPageItemObservable 의 모든 키 (순서대로)
    var pageCollectionViewCurrentCellIndex: Observable<IndexPath>!
    
    // for EditMode
    var oldDiary: Diary!
    var currentPageItemObservable: Observable<[Item]>!
    var pageIndexDescriptionObservable: Observable<String>!
    var maxPageIndexObservable: Observable<Int>!
    
    init(diary: Diary, selectedDayIndex: Int) async {
        self.selectedPageIndex = BehaviorSubject(value: (selectedDayIndex,0))
        self.diaryObservable = await setDiaryObservable(diary: diary)
        
        self.allPageItemObservable = await setAllPageItemObservable()
        self.maxPageIndexByDayObservable = await setMaxPageIndexByDayObservable()
        self.allPageItemKeys = await setAllPageItemKeys()
        self.pageCollectionViewCurrentCellIndex  = await setPageCollectionViewCurrentCellIndex()
        
        self.currentPageItemObservable = await setCurrentPageItemObservable()
        self.pageIndexDescriptionObservable = await setPageIndexDescriptionObservable()
        self.maxPageIndexObservable = await setMaxPageIndexObservable()
        await setDiaryDBUpdate()
    }

    func setOldDiary() {
        self.diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                print($0.diaryUUID)
                self.oldDiary = $0
            })
            .disposed(by: disposeBag)
    }
    
    func setDiaryObservable(diary: Diary) async -> BehaviorSubject<Diary> {
        return BehaviorSubject(value: diary)
    }
    
    /// diaryObservable 에 새 값이 전달될때 마다 서버 db에 업데이트
    func setDiaryDBUpdate() async {
        self.diaryObservable
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe { diary in
                FirebaseClient().updatePage(diary: diary)
            }
            .disposed(by: disposeBag)
    }
    
    func setAllPageItemObservable() async -> Observable<[String:[Item]]> {
        self.diaryObservable
            .observe(on: MainScheduler.instance)
            .map {
                var returnVal: [String:[Item]] = [:]
                
                $0.diaryPages.enumerated().forEach { (pagesIndex, pages) in
                    pages.pages.enumerated().forEach { (pageIndex, page) in
                        let pageKey = pagesIndex.description + "." + pageIndex.description
                        returnVal[pageKey] = page.items
                    }
                }

                return returnVal
            }
    }
    
    func setMaxPageIndexByDayObservable() async -> Observable<[Int]> {
        self.diaryObservable
            .observe(on: MainScheduler.instance)
            .map {
                var resultVal: [Int] = []
                
                $0.diaryPages.forEach { (pages) in
                    resultVal.append(pages.pages.count - 1)
                }

                return resultVal
            }
    }
    
    func setAllPageItemKeys() async -> Observable<[String]> {
        return maxPageIndexByDayObservable
            .map {
                var resultVal: [String] = []
                
                $0.enumerated().forEach { (dayIndex, maxPageIndex) in
                    for i in 0...maxPageIndex {
                        let key = dayIndex.description + "." + i.description
                        resultVal.append(key)
                    }
                }
                
                return resultVal
            }
    }
    
    func setPageCollectionViewCurrentCellIndex() async-> Observable<IndexPath>{
        return Observable
            .combineLatest(selectedPageIndex, maxPageIndexByDayObservable) { (selectedPageIndex, maxPageIndexes) in
                
                var cellIndex = selectedPageIndex.1
                
                if selectedPageIndex.0 != 0 {
                    (0 ..< selectedPageIndex.0).forEach {
                        cellIndex += (maxPageIndexes[$0] + 1)
                    }
                }
                
                return IndexPath(item: cellIndex, section: 0)
            }
    }
    
    func setCurrentPageItemObservable() async -> Observable<[Item]> {
        return Observable.combineLatest(diaryObservable, selectedPageIndex)
            .map { (diary, selectedPageIndex) in
                diary.diaryPages[selectedPageIndex.0].pages[selectedPageIndex.1].items
            }
    }
    
    func setPageIndexDescriptionObservable() async -> Observable<String> {
        return Observable.combineLatest(diaryObservable, selectedPageIndex)
            .map { (diary, selectedPageIndex) in
                let pagesCount = diary.diaryPages[selectedPageIndex.0].pages.count
                return (selectedPageIndex.1 + 1).description + "/" + pagesCount.description
            }
    }
    
    func setMaxPageIndexObservable() async -> Observable<Int> {
        return Observable.combineLatest(diaryObservable, selectedPageIndex)
            .map { (diary, selectedPageIndex) in
                let pagesCount = diary.diaryPages[selectedPageIndex.0].pages.count
                return pagesCount - 1
            }
    }
    
    // PageViewMode
    func collectionViewIndexPathHasChanged(targetIndexPath: Int) {
        
        maxPageIndexByDayObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .map { maxPageIndexes in
                var selectedDayIndex = 0
                var currentPageIndex = targetIndexPath

            Util:for maxPageIndex in maxPageIndexes {
                    guard currentPageIndex > maxPageIndex else { break Util }
                    currentPageIndex -= (maxPageIndex + 1)
                    selectedDayIndex += 1
                }

                return (selectedDayIndex, currentPageIndex)
            }
            .subscribe(onNext: {
                self.selectedPageIndex.onNext($0)
            })
            .disposed(by: disposeBag)

    }
    
    // PageEditMode
    func restoreOldDiary() {
        self.diaryObservable.onNext(self.oldDiary)
    }
    
    func addNewPage(to: AddPage) {
        let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let newPage = Page(pageUUID: pageUUID, items: [])
        
        diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                do {
                    var newDiary = $0
                    let selectedDayIndex = try self.selectedPageIndex.value().0
                    let newPageIndex = try self.selectedPageIndex.value().1 + 1
                    
                    switch to {
                    case .nextToCurrentPage:
                        newDiary.diaryPages[selectedDayIndex].pages.insert(newPage, at: newPageIndex)
                        
                    case .nextToLastPage:
                        newDiary.diaryPages[selectedDayIndex].pages.append(newPage)
                    }
                    
                    self.diaryObservable.onNext(newDiary)
                    self.selectedPageIndex.onNext((selectedDayIndex, newPageIndex))
                } catch {
                    print(error)
                }

            })
            .disposed(by: disposeBag)
    }
    
    func deleteCurrentPage() {
        
        diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                do {
                    var newDiary = $0
                    let selectedDayIndex = try self.selectedPageIndex.value().0
                    let selectedPageIndex = try self.selectedPageIndex.value().1
                    
                    newDiary.diaryPages[try self.selectedPageIndex.value().0].pages.remove(at: selectedPageIndex)
                    
                    self.maxPageIndexObservable
                        .observe(on: MainScheduler.instance)
                        .take(1)
                        .subscribe(onNext: {
                            if $0 == 0 {
                                
                                print("한 장 입니다.")
                                
                            } else if selectedPageIndex == $0 {
                                
                                self.selectedPageIndex.onNext((selectedDayIndex, selectedPageIndex - 1))
                                self.diaryObservable.onNext(newDiary)
                                
                            } else {
                                
                                self.diaryObservable.onNext(newDiary)
                                
                            }
                        })
                        .disposed(by: self.disposeBag)
                
                } catch {
                    print(error)
                }
            })
            .disposed(by: disposeBag)

    }
    
    func moveToNextPage() {
        
        Observable
            .combineLatest(self.selectedPageIndex, self.maxPageIndexObservable)
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe { (selectedPageIndex, maxPageIndex) in
                if selectedPageIndex.1 + 1 <= maxPageIndex {
                    self.selectedPageIndex.onNext((selectedPageIndex.0, selectedPageIndex.1 + 1))
                } else {
                    print("마지막 페이지입니다.")
                }
            }.disposed(by: self.disposeBag)
        
    }

    func moveToPreviousPage() {
        
        self.selectedPageIndex
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                
                if $0.1 - 1 >= 0 {
                    self.selectedPageIndex.onNext(($0.0, $0.1 - 1))
                } else {
                    print("첫 페이지입니다.")
                }
                
            })
            .disposed(by: disposeBag)

    }

    func updateCurrentPageDataToDiaryModel(stickerViews: [StickerView]) {
        
        Observable.just(stickerViews)
            .observe(on: MainScheduler.instance)
            .take(1)
            .map {
                var newItems: [Item] = []
                
                for stickerView in $0 {
                    newItems.append(try stickerView.fetchItem())
                }
                
                return newItems
            }.subscribe(onNext: { newItems in
                
                let selectedDay = try! self.selectedPageIndex.value().0
                let currentPageIndex = try! self.selectedPageIndex.value().1
                
                self.diaryObservable
                    .observe(on: MainScheduler.instance)
                    .take(1)
                    .subscribe(onNext: {
                        var newDiary = $0
                        newDiary.diaryPages[selectedDay].pages[currentPageIndex].items = newItems
                        
                        self.diaryObservable.onNext(newDiary)
                    })
                    .disposed(by: self.disposeBag)
                
            })
            .disposed(by: self.disposeBag)
        
    }

}
