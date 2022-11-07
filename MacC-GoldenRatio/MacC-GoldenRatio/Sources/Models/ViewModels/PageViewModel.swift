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
    var selectedDay: BehaviorSubject<Int>!
    var currentPageIndex: BehaviorSubject<Int> = BehaviorSubject(value: 0)
    
    var currentPageItemObservable: Observable<[Item]>!
    var pageIndexDescriptionObservable: Observable<String>!
    var maxPageIndexObservable: Observable<Int>!
    
    init(diary: Diary, selectedDay: Int) async {
        // TODO: 선행 뷰에게서 diary 받아와서 init 하기
        self.selectedDay = BehaviorSubject(value: selectedDay)
        self.diaryObservable = await setDiaryObservable(diary: diary)
        self.currentPageItemObservable = await setCurrentPageItemObservable()
        self.pageIndexDescriptionObservable = await setPageIndexDescriptionObservable()
        self.maxPageIndexObservable = await setMaxPageIndexObservable()
        await setDiaryUpdate()
    }
    
    func setDiaryObservable(diary: Diary) async -> BehaviorSubject<Diary> {
        return BehaviorSubject(value: diary)
    }
    
    func setDiaryUpdate() async {
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
                return pagesCount
            }
    }
    
    func addNewPage(to: AddPage) {
        let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let newPage = Page(pageUUID: pageUUID, items: [])
        
        diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                var newDiary = $0
                do {
                    switch to {
                    case .nextToCurrentPage:
                        let newPageIndex = try self.currentPageIndex.value() + 1
                        newDiary.diaryPages[try self.selectedDay.value()].pages.insert(newPage, at: newPageIndex)
                        
                    case .nextToLastPage:
                        newDiary.diaryPages[try self.selectedDay.value()].pages.append(newPage)
                    }
                } catch {
                    print(error)
                }
                
                self.diaryObservable.onNext(newDiary)
            })
            .disposed(by: disposeBag)
    }
    
    func deletePage() {
        
        diaryObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                var newDiary = $0
                do {
                    newDiary.diaryPages[try self.selectedDay.value()].pages.remove(at: try self.currentPageIndex.value())
                } catch {
                    print(error)
                }
                self.diaryObservable.onNext(newDiary)
            })
            .disposed(by: disposeBag)

    }
    
    func moveToNextPage() async {
        
        self.currentPageIndex
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { currentPageIndex in

                var maxPageIndex = 0

                self.maxPageIndexObservable
                    .take(1)
                    .subscribe(onNext: {
                        maxPageIndex = $0
                    })
                    .disposed(by: self.disposeBag)
                
                if currentPageIndex + 2 <= maxPageIndex {
                    print(currentPageIndex)
                    self.currentPageIndex.onNext(currentPageIndex + 1)
                } else {
                    print("마지막 페이지입니다.")
                }
                
            })
            .disposed(by: disposeBag)

    }

    func moveToPreviousPage() async {
        
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
        
        DispatchQueue.global().async {
            do {
                var newItems: [Item] = []
                
                for stickerView in stickerViews {
                    newItems.append(try stickerView.fetchItem())
                }
                
                let selectedDay = try self.selectedDay.value()
                let currentPageIndex = try self.currentPageIndex.value()
                
                self.diaryObservable
                    .observe(on: MainScheduler.instance)
                    .take(1)
                    .subscribe(onNext: {
                        var newDiary = $0
                        newDiary.diaryPages[selectedDay].pages[currentPageIndex].items = newItems
                        
                        self.diaryObservable.onNext(newDiary)
                    })
                    .disposed(by: self.disposeBag)
            } catch {
                print(error)
            }
        }
        
    }
        
    func updateDBPages() {
        DispatchQueue.global().async {
            do {

                let diary = try self.diaryObservable.value()
                FirebaseClient().updatePage(diary: diary)
                
            } catch {
                print(error)
            }
        }
    }
}
