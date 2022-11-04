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
    }
    
    func setDiaryObservable(diary: Diary) async -> BehaviorSubject<Diary> {
        return BehaviorSubject(value: diary)
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
            .subscribe(on: MainScheduler.instance)
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
            .subscribe(on: MainScheduler.instance)
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
    
    func moveToNextPage() {
        
        self.currentPageIndex
            .subscribe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: { currentPageIndex in
                
                DispatchQueue.main.async {
                    var maxPageIndex = 0
                    self.maxPageIndexObservable
                        .subscribe(on: MainScheduler.instance)
                        .take(1)
                        .subscribe(onNext: {
                            maxPageIndex = $0
                        })
                        .disposed(by: self.disposeBag)

                    if currentPageIndex + 2 <= maxPageIndex {
                        self.currentPageIndex.onNext(currentPageIndex + 1)
                    } else {
                        print("마지막 페이지입니다.")
                    }
                }
                
            })
            .disposed(by: disposeBag)

    }

    func moveToPreviousPage() {
        
        self.currentPageIndex
            .observe(on:MainScheduler.asyncInstance)
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
    
    func appendSticker(_ sticker: StickerView) {
//        stickerArrayObservable[currentPageIndex].append(sticker)
    }
    
    func removeSticker(_ sticker: StickerView) {
//        guard let index = stickerArrayObservable[currentPageIndex].firstIndex(of: sticker) else { return }
//        stickerArrayObservable[currentPageIndex].remove(at: index)
    }
    
    func hideStickerSubview(_ value: Bool) {
//        stickerArrayObservable.forEach{
//            $0.forEach{ stickerView in
//                stickerView.changeLastEditor(lastEditor: nil)
//            }
//        }
    }
    
    func bringStickerToFront(_ sticker: StickerView) {
//        guard let index = stickerArrayObservable[currentPageIndex].firstIndex(of: sticker) else { return }
//        stickerArrayObservable[currentPageIndex].remove(at: index)
//        stickerArrayObservable[currentPageIndex].append(sticker)
    }
    
    
    
//    func setStickerArray() async -> Observable<[[StickerView]]> {
//        self.diaryObservable
//            .map { diary in
//                diary.diaryPages[self.selectedDay].pages.map {
//                    let stickerViews: [StickerView] = $0.items.map { item in
//                        switch item.itemType {
//                        case .text:
//                            return await TextStickerView(item: item)
//                        case .image:
//                            return await ImageStickerView(item: item)
//                        case .sticker:
//                            return await StickerStickerView(item: item)
//                        case .location:
//                            return await MapStickerView(item: item)
//                        }
//                    }
//                    return stickerViews
//                }
//            }
//    }
//
//    func updateDBPages() {
//        do {
//            let items = try stickerArrayObservable.map{
//                try $0.map{
//                    guard let stickerViewData = $0.stickerViewData else { throw ErrorMessage.stickerViewDataDoesntExist }
//                    return try stickerViewData.itemObservable.value()
//                }
//            }
//            items.enumerated().forEach{
//                diary.diaryPages[selectedDay].pages[$0].items = $1
//            }
//        } catch {
//            print(error)
//        }
//
//        FirebaseClient().updatePage(diary: diary)
//    }
}
