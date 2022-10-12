//
//  PageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/02.
//

import UIKit

class PageViewModel {
    var selectedDay: Int = 0
    var currentPageIndex: Int = 0
    var stickerArray: [[StickerView]] = []
    var diary: Diary!

//    var diary = Diary(diaryUUID: "diaryUUID2", diaryName: "포항항", diaryLocation: Location(locationName: "포항영일대", locationAddress: "포항영일대주소", locationCoordinate: [36.020107332983, 129.32530987999]), diaryStartDate: "2022년 10월 4일", diaryEndDate: "2022년 10월 4일",  userUIDs: ["testUser"], diaryPages: [
//        Pages(pages:
//                [Page(pageUUID: "PageUUID", items: [Item(itemUUID: UUID().uuidString, itemType: .text, contents: ["화려한 불빛으로\n 그 뒷 모습만 보이며 \n안녕이란 말도 없이 사라진 그대"], itemFrame: [28,55,220,320], itemBounds: [0,0,220,320], itemTransform: [0.75815426405639663, 0.6520752348411214, -0.6520752348411214, 0.75815426405639663, 0, 0]), Item(itemUUID: UUID().uuidString, itemType: .text, contents: ["화려한 불빛으로"], itemFrame: [28,55,220,320], itemBounds: [0,0,220,320], itemTransform: [0.75815426405639663, 0.6520752348411214, -0.6520752348411214, 0.75815426405639663, 0, 0])]),
//                 Page(pageUUID: "PageUUID", items: [Item(itemUUID: UUID().uuidString, itemType: .text, contents: ["화려한 불빛으로"], itemFrame: [28,55,220,320], itemBounds: [0,0,220,320], itemTransform: [0.75815426405639663, 0.6520752348411214, -0.6520752348411214, 0.75815426405639663, 0, 0])])]
//             )
//    ])

    init() {
        // TODO: 선행 뷰에게서 diary 받아와서 init 하기
        Task{
            diary = try! await (FirebaseClient().fetchMyDiaries(uid: "testUser")?.first)!
            setStickerArray()
        }
    }
    
    func addNewPage() {
        let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let newPage = Page(pageUUID: pageUUID, items: [])
        diary.diaryPages[selectedDay].pages.append(newPage)
        
        stickerArray.append([])
    }

    func setStickerArray() {
        DispatchQueue.main.async {
            self.diary.diaryPages[self.selectedDay].pages.forEach{
                let stickerViews: [StickerView] = $0.items.map {
                    switch $0.itemType {
                    case .text:
                        return TextStickerView(item: $0)
                    case .image:
                        return ImageStickerView(item: $0)
                    case .sticker:
                        return StickerStickerView(item: $0)
                    case .location:
                        return MapStickerView(item: $0)
                    }
                }
                self.stickerArray.append(stickerViews)
            }
        }
    }
    
    func appendSticker(_ sticker: StickerView) {
        stickerArray[currentPageIndex].append(sticker)
    }
    
    func removeSticker(_ sticker: StickerView) {
        guard let index = stickerArray[currentPageIndex].firstIndex(of: sticker) else { return }
        stickerArray[currentPageIndex].remove(at: index)
    }
    
    func stickerSubviewHidden(_ value: Bool) {
        stickerArray.forEach{
            $0.forEach{
                $0.subviewIsHidden = value
            }
        }
    }
    
    func bringStickerToFront(_ sticker: StickerView) {
        guard let index = stickerArray[currentPageIndex].firstIndex(of: sticker) else { return }
        stickerArray[currentPageIndex].remove(at: index)
        stickerArray[currentPageIndex].append(sticker)
        debugPrint(stickerArray)
    }
    
    func upLoadImage(image: UIImage, _ completion: @escaping () -> Void) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: diary.diaryUUID + "/thumbnail") { url in
            guard let url = url else { return }
            self.diary.pageThumbnails[self.selectedDay] = url.description
            completion()
        }
    }
    
    func updatePageThumbnail() {
        FirebaseClient().updatePageThumbnail(diary: diary)
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
