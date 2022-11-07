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

    var oldDiary: Diary!
    
    var diaryObservable: BehaviorSubject<Diary>!
    var selectedDay: BehaviorSubject<Int>!
    var currentPageIndex: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    var currentPageItemObservable: Observable<[Item]>!
    var pageIndexDescriptionObservable: Observable<String>!
    var maxPageIndexObservable: Observable<Int>!
    
    init(diary: Diary, selectedDay: Int) async {
        self.oldDiary = diary
        self.selectedDay = BehaviorSubject(value: selectedDay)
        self.diaryObservable = await setDiaryObservable(diary: diary)
        self.currentPageItemObservable = await setCurrentPageItemObservable()
        self.pageIndexDescriptionObservable = await setPageIndexDescriptionObservable()
        self.maxPageIndexObservable = await setMaxPageIndexObservable()
        await setDiaryDBUpdate()
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
    
    func setCurrentPageItemObservable() async -> Observable<[Item]> {
        return Observable.combineLatest(diaryObservable, selectedDay, currentPageIndex)
            .map { (diary, selectedDay, currentPageIndex) in
                diary.diaryPages[selectedDay].pages[currentPageIndex].items
            }
    }
    
    func setPageIndexDescriptionObservable() async -> Observable<String> {
        return Observable.combineLatest(diaryObservable, selectedDay, currentPageIndex)
            .map { (diary, selectedDay, currentPageIndex) in
                let pagesCount = diary.diaryPages[selectedDay].pages.count
                return (currentPageIndex + 1).description + "/" + pagesCount.description
            }
    }
    
    func setMaxPageIndexObservable() async -> Observable<Int> {
        return Observable.combineLatest(diaryObservable, selectedDay, currentPageIndex)
            .map { (diary, selectedDay, currentPageIndex) in
                let pagesCount = diary.diaryPages[selectedDay].pages.count
                return pagesCount - 1
            }
    }
    
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
                    let selectedDay = try self.selectedDay.value()
                    let newPageIndex = try self.currentPageIndex.value() + 1
                    
                    switch to {
                    case .nextToCurrentPage:
                        newDiary.diaryPages[selectedDay].pages.insert(newPage, at: newPageIndex)
                        
                    case .nextToLastPage:
                        newDiary.diaryPages[selectedDay].pages.append(newPage)
                    }
                    
                    self.diaryObservable.onNext(newDiary)
                    self.currentPageIndex.onNext(newPageIndex)
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
                    let currentPageIndex = try self.currentPageIndex.value()
                    
                    newDiary.diaryPages[try self.selectedDay.value()].pages.remove(at: currentPageIndex)
                    
                    self.maxPageIndexObservable
                        .observe(on: MainScheduler.instance)
                        .take(1)
                        .subscribe(onNext: {
                            if $0 == 0 {
                                print("한 장 입니다.")
                                
                            } else if currentPageIndex == $0 {
                                
                                self.currentPageIndex.onNext(currentPageIndex - 1)
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
        
        self.currentPageIndex
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { currentPageIndex in

                self.maxPageIndexObservable
                    .observe(on: MainScheduler.instance)
                    .take(1)
                    .subscribe(onNext: {
                        
                        if currentPageIndex + 1 <= $0 {
                            self.currentPageIndex.onNext(currentPageIndex + 1)
                        } else {
                            print("마지막 페이지입니다.")
                        }
                        
                    })
                    .disposed(by: self.disposeBag)
                
            })
            .disposed(by: disposeBag)

    }

    func moveToPreviousPage() {
        
        self.currentPageIndex
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                
                if $0 - 1 >= 0 {
                    self.currentPageIndex.onNext($0 - 1)
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
                
                let selectedDay = try! self.selectedDay.value()
                let currentPageIndex = try! self.currentPageIndex.value()
                
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
