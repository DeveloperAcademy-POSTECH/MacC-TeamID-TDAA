//
//  PageEditModeViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/19.
//

import RxSwift
import UIKit

class PageEditModeViewModel {
    
    enum AddPage {
        case nextToCurrentPage
        case nextToLastPage
    }
    
    var disposeBag = DisposeBag()
    
    var diaryObservable: BehaviorSubject<Diary>!
    var selectedPageIndexSubject: BehaviorSubject<(Int,Int)>! // n 일차에 m 번째 페이지.
    
    var oldDiary: Diary!
    var currentPageItemObservable: Observable<[Item]>!
    var pageIndexDescriptionObservable: Observable<String>!
    var maxPageIndexObservable: Observable<Int>!
    
    let pageViewModelSerialQueueName: String = "pageViewModelSerialQueue"
    lazy var pageViewModelSerialQueue = SerialDispatchQueueScheduler(qos: .userInteractive, internalSerialQueueName: pageViewModelSerialQueueName)
    
    init(diary: Diary, selectedPageIndex: (Int, Int)) {
        self.diaryObservable = BehaviorSubject(value: diary)
        self.selectedPageIndexSubject = BehaviorSubject(value: selectedPageIndex)
        
        self.currentPageItemObservable = setCurrentPageItemObservable()
        self.pageIndexDescriptionObservable = setPageIndexDescriptionObservable()
        self.maxPageIndexObservable = setMaxPageIndexObservable()
        setOldDiary()
        setDiaryDBUpdate()
    }
    
    func setCurrentPageItemObservable() -> Observable<[Item]> {
        return Observable.combineLatest(diaryObservable, selectedPageIndexSubject)
            .map { (diary, selectedPageIndex) in
                return diary.diaryPages[selectedPageIndex.0].pages[selectedPageIndex.1].items
            }
    }
    
    func setPageIndexDescriptionObservable() -> Observable<String> {
        return Observable.combineLatest(diaryObservable, selectedPageIndexSubject)
            .map { (diary, selectedPageIndex) in
                let pagesCount = diary.diaryPages[selectedPageIndex.0].pages.count
                return (selectedPageIndex.1 + 1).description + "/" + pagesCount.description
            }
    }
    
    func setMaxPageIndexObservable() -> Observable<Int> {
        return Observable.combineLatest(diaryObservable, selectedPageIndexSubject)
            .map { (diary, selectedPageIndex) in
                let pagesCount = diary.diaryPages[selectedPageIndex.0].pages.count
                return pagesCount - 1
            }
    }
    
    /// diaryObservable 에 새 값이 전달될때 마다 서버 db에 업데이트
    func setDiaryDBUpdate() {
        self.diaryObservable
            .observe(on: ConcurrentDispatchQueueScheduler(qos: .default))
            .subscribe { diary in
                FirebaseClient().updatePage(diary: diary)
            }
            .disposed(by: disposeBag)
    }
    
    func setOldDiary() {
        self.diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                self.oldDiary = $0
            })
            .disposed(by: disposeBag)
    }
    
    // MARK: PageEditMode 메서드
    func restoreOldDiary() {
        self.diaryObservable.onNext(self.oldDiary)
    }
    
    func addNewPage(to: AddPage) {
        var selectedDayIndex = 0
        var newPageIndex = 0
        
        selectedPageIndexSubject
            .subscribe(on: self.pageViewModelSerialQueue)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe {
                selectedDayIndex = $0.0
                newPageIndex = $0.1 + 1
            }
            .disposed(by: self.disposeBag)
        
        diaryObservable
            .subscribe(on: self.pageViewModelSerialQueue)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe(onNext: {
                var newDiary = $0
                let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
                let newPage = Page(pageUUID: pageUUID, items: [])
                
                switch to {
                case .nextToCurrentPage:
                    newDiary.diaryPages[selectedDayIndex].pages.insert(newPage, at: newPageIndex)
                    
                case .nextToLastPage:
                    newDiary.diaryPages[selectedDayIndex].pages.append(newPage)
                }
                
                self.diaryObservable.onNext(newDiary)
                self.selectedPageIndexSubject.onNext((selectedDayIndex, newPageIndex))
            })
            .disposed(by: disposeBag)
    }
    
    func deleteCurrentPage() {
        var selectedDayIndex = 0
        var selectedPageIndex = 0
        
        selectedPageIndexSubject
            .subscribe(on: self.pageViewModelSerialQueue)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe {
                selectedDayIndex = $0.0
                selectedPageIndex = $0.1
            }
            .disposed(by: self.disposeBag)
        
        diaryObservable
            .subscribe(on: self.pageViewModelSerialQueue)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe(onNext: {
                var newDiary = $0
                
                newDiary.diaryPages[selectedDayIndex].pages.remove(at: selectedPageIndex)
                
                self.maxPageIndexObservable
                    .observe(on: self.pageViewModelSerialQueue)
                    .take(1)
                    .subscribe(onNext: {
                        if $0 == 0 {
                            print("한 장 입니다.")
                        } else if selectedPageIndex == $0 {
                            self.selectedPageIndexSubject.onNext((selectedDayIndex, selectedPageIndex - 1))
                            self.diaryObservable.onNext(newDiary)
                        } else {
                            self.diaryObservable.onNext(newDiary)
                        }
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
    }
    
    func moveToNextPage() {
        
        Observable
            .combineLatest(selectedPageIndexSubject, maxPageIndexObservable)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe { (selectedPageIndex, maxPageIndex) in
                if selectedPageIndex.1 + 1 <= maxPageIndex {
                    self.selectedPageIndexSubject.onNext((selectedPageIndex.0, selectedPageIndex.1 + 1))
                } else {
                    print("마지막 페이지입니다.")
                }
            }.disposed(by: self.disposeBag)
        
    }

    func moveToPreviousPage() {
        
        selectedPageIndexSubject
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe(onNext: {
                
                if $0.1 - 1 >= 0 {
                    self.selectedPageIndexSubject.onNext(($0.0, $0.1 - 1))
                } else {
                    print("첫 페이지입니다.")
                }
                
            })
            .disposed(by: disposeBag)

    }

    func updateCurrentPageDataToDiaryModel(backgroundView: UIView) {
        var selectedDayIndex = 0
        var selectedPageIndex = 0
        
        selectedPageIndexSubject
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .subscribe {
                selectedDayIndex = $0.0
                selectedPageIndex = $0.1
            }
            .disposed(by: self.disposeBag)
        
        Observable.just(backgroundView.subviews)
            .observe(on: self.pageViewModelSerialQueue)
            .take(1)
            .map {
                var newItems: [Item] = []

                $0.forEach {
                    if let stickerView = $0 as? StickerView {
                        if let item = try? stickerView.fetchItem() {
                            newItems.append(item)
                        }
                    }
                }
                
                return newItems
            }
            .subscribe(onNext: { newItems in
                if var newDiary = try? self.diaryObservable.value() {
                    newDiary.diaryPages[selectedDayIndex].pages[selectedPageIndex].items = newItems
                    
                    self.diaryObservable.onNext(newDiary)
                }
            })
            .disposed(by: self.disposeBag)
    }
}
