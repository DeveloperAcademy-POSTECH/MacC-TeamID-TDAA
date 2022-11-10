//
//  MyDiaryDaysModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import FirebaseFirestore
import FirebaseAuth
import RxSwift
import UIKit

struct MyDiaryDaysModel {
    let db = Firestore.firestore()
    var diary: Diary
    let myUID = Auth.auth().currentUser?.uid ?? ""
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    // 완료된 정보를 뷰모델에 전달하면 됨!
    // 가지고 있을 정보 -> 다이어리 데이터, 이미지 데이터 ~ 다운로드는 하나만 하면 됨! 모두 다운로드 할 필요가 없음
    
    mutating func updateDiaryData() async throws -> Observable<Diary> {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: self.diary.diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        self.diary = data
        return Observable.just(data)
    }
    
    func fetchImages(day: Int) -> Observable<[UIImage?]> {
        // let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: self.diary.diaryUUID).whereField("diaryPages")
        var imageArray: [UIImage?] = []
        
        self.diary.diaryPages[day].pages.forEach { page in // 해당 일차의 페이지
            page.items.forEach { item in // 각 페이지의 아이템
                if item.itemType == .image {
                    DispatchQueue.global(qos: .background).async {
                        let url = item.contents[0]
                        guard let image = ImageManager.shared.searchImage(urlString: url) else {
                            FirebaseStorageManager.downloadImage(urlString: url) { result in
                                imageArray.append(result)
                                ImageManager.shared.cacheImage(urlString: url, image: result ?? UIImage())
                            }
                            return
                        }
                        imageArray.append(image)
                    }
                }
            }
        }
        
        return Observable.just(imageArray)
    }
    
    func makeDateString(day: Int) -> String {
        guard let startDate = self.diary.diaryStartDate.toDate() else { return "" }
        guard let currentDate = Calendar.current.date(byAdding: .day, value: day - 1, to: startDate) else { return "" }
        let labelDayOfWeek = currentDate.dayOfTheWeek()
        
        return "\(currentDate.customFormat()) (\(labelDayOfWeek))"
    }
    
    func outCurrentDiary() {
        // 다이어리 UID에서 자신 삭제
        let userUIDs = self.diary.userUIDs.filter(){ $0 != myUID }
        let diaryRef = db.collection("Diary").document(self.diary.diaryUUID)
        

        if userUIDs.isEmpty {
            // 자신밖에 없으면 다이어리 삭제
            diaryRef.delete() { err in
                if let _ = err {
                    print("ERROR: 다이어리 삭제 실패")
                } else {
                    print("다이어리 삭제 완료")
                }
            }
        } else {
            let pagesFieldData = ["userUIDs" : userUIDs]
            diaryRef.updateData(pagesFieldData)
        }
    }
}
