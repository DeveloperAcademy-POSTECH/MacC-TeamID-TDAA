//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import UIKit

enum EditType {
    case add
    case remove
    case modify
}

struct EditPage {
    var pageIndex: Int
    var sticker: StickerView
    var editType: EditType
    
}

class PageViewModel {
    var selectedDay: Int = 0
    var currentPageIndex: Int = 0
    @Published var diary: Diary = Diary(diaryUUID: "", diaryName: "", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: []), diaryStartDate: "", diaryEndDate: "", diaryCover: "")
    @Published var stickerArray: [[StickerView]] = []
    var isStickerArrayOutdated: Bool = false
    var oldPageIndex: Int = 0
    var oldDiary: Diary!
//    var editStack

    init(diary: Diary, selectedDay: Int) {
        // TODO: 선행 뷰에게서 diary 받아와서 init 하기
        self.diary = diary
        self.selectedDay = selectedDay
        bindDiarySnapshotListner()
    }
    
    func saveOldData() {
        oldPageIndex = currentPageIndex
        oldDiary = diary
    }
    
    func restoreOldData() {
        currentPageIndex = oldPageIndex
        diary = oldDiary

//        var oldItemDic: [String:Item] = [:]
//        oldDiary.diaryPages[selectedDay].pages.forEach{ page in
//            page.items.forEach{ item in
//                oldItemDic[item.itemUUID] = item
//            }
//        }
//
//        diary.diaryPages[selectedDay].pages.enumerated().forEach{ (index, page) in
//            let newItems = page.items.map { item in
//                if let oldItem = oldItemDic[item.itemUUID] {
//                    return oldItem
//                }
//                return item
//            }
//            diary.diaryPages[selectedDay].pages[index].items = newItems
//        }
    }
    
    func addNewPage() {
        let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let newPage = Page(pageUUID: pageUUID, items: [])
        diary.diaryPages[selectedDay].pages.append(newPage)
        
        stickerArray.append([])
    }
    
    func deletePage() {
        diary.diaryPages[selectedDay].pages.remove(at: currentPageIndex)
        stickerArray.remove(at: currentPageIndex)
    }

    func appendSticker(_ sticker: StickerView) {
        stickerArray[currentPageIndex].append(sticker)
    }
    
    func removeSticker(_ sticker: StickerView) {
        guard let index = stickerArray[currentPageIndex].firstIndex(of: sticker) else { return }
        stickerArray[currentPageIndex].remove(at: index)
    }
    
    func hideStickerSubview(_ value: Bool) {
        stickerArray.forEach{
            $0.forEach{
                if $0.isSubviewHidden != value {
                    if $0.borderMode == .me {
                        $0.isSubviewHidden = value
                    }
                }
            }
        }
    }
    
    func bringStickerToFront(_ sticker: StickerView) {
        guard let index = stickerArray[currentPageIndex].firstIndex(of: sticker) else { return }
        stickerArray[currentPageIndex].remove(at: index)
        stickerArray[currentPageIndex].append(sticker)
    }
    
    func bindDiarySnapshotListner() {
        FirebaseClient().bindSnapshotListner(diaryUUID: diary.diaryUUID) { snapShot in
            do {
                let diary = try snapShot.data(as: Diary.self)
                self.diary = diary
                self.setStickerArray()
                self.isStickerArrayOutdated = true
            } catch {
                self.setStickerArray()
                print(error)
            }
        }
    }
    
    func setStickerArray() {
        self.stickerArray = self.diary.diaryPages[self.selectedDay].pages.map{
            let stickerViews: [StickerView] = $0.items.map {
                var stickerView: StickerView!
                switch $0.itemType {
                case .text:
                    stickerView = TextStickerView(item: $0)
                case .image:
                    stickerView = ImageStickerView(item: $0)
                case .sticker:
                    stickerView = StickerStickerView(item: $0)
                case .location:
                    stickerView = MapStickerView(item: $0)
                }
                return stickerView
            }
            return stickerViews
        }
    }
    
    func updatePageThumbnail() {
        FirebaseClient().updatePageThumbnail(diary: diary)
    }
    
    func upLoadThumbnail(image: UIImage, _ completion: @escaping () -> Void) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: "Diary/" + diary.diaryUUID.description + "/thumbnail") { url in
            guard let url = url else { return }
            self.diary.pageThumbnails[self.selectedDay] = url.description
            completion()
        }
    }
    
    func updateDBPages() {
        let items = stickerArray.map{
            $0.map{
                $0.stickerViewData.item
            }
        }
        items.enumerated().forEach{
            diary.diaryPages[selectedDay].pages[$0].items = $1
        }
        FirebaseClient().updatePage(diary: diary)
    }
}
