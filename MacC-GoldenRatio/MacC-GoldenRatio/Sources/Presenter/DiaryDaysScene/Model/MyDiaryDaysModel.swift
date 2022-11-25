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

class MyDiaryDaysModel {
    let disposeBag = DisposeBag()
    let db = Firestore.firestore()
    var diary: Diary
    let myUID = Auth.auth().currentUser?.uid ?? ""
    
    init(diary: Diary) {
        self.diary = diary
    }
    
    func fetchDiaryDataObservable() async throws -> Observable<Diary> {
        return Observable.just(diary)
    }
    
    func updateDiaryData() async throws -> Observable<Diary> {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: self.diary.diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        self.diary = data
        return Observable.just(data)
    }
    
    func diaryDataSetup(_ completion: @escaping () -> Void) {
        Task {
            self.diary = try await getDiaryData()
            completion()
        }
    }
    
    func getDiaryData() async throws -> Diary {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: self.diary.diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        return data
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
    
    func daysToArray(model: MyDiaryDaysModel) -> [DiaryDayModel] {
        let days = model.diary.diaryPages.count
        var dataForCellData: [DiaryDayModel] = []
        
        for day in 1...days {
            // Model -> ViewModel
            dataForCellData.append(self.diaryToDayModel(model: model, selectedDay: day))
        }
        return dataForCellData
    }
    
    // 썸네일 URL이 있으면 전달, 없으면 랜덤하게 띄우기
    func diaryToDayModel(model: MyDiaryDaysModel, selectedDay: Int) -> DiaryDayModel {
        let dayLabelData = "\(selectedDay)일차"
        let dateLabelData = model.makeDateString(day: selectedDay)
        var diaryDayModel = DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: nil)
        let thumbnailURLString:String? = model.diary.pageThumbnails[selectedDay-1]
        
        if self.checkThumbnailValid(url: thumbnailURLString) {
            // 썸네일 이미지 URL이 있는 경우 -> 이미지 다운로드 후 리턴
            guard let thumbnailURLString = thumbnailURLString else { return diaryDayModel }
            if let image = ImageManager.shared.searchImage(urlString: thumbnailURLString) {
                // 썸네일 있고 캐시에 이미지 있음
                diaryDayModel = DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: image)
            } else {
                FirebaseStorageManager.downloadImage(urlString: thumbnailURLString) { image in
                    ImageManager.shared.cacheImage(urlString: thumbnailURLString, image: image ?? UIImage())
                    // 썸네일 있고 파베에 이미지 있음
                    diaryDayModel = DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: image)
                }
            }
            
        } else {
            // 썸네일 이미지 URL이 없는 경우 -> 앨범 내의 Random한 이미지 리턴
            model.fetchRandomImage(day: selectedDay)
                .subscribe(onNext: {
                    let imageData: UIImage? = $0
                    
                    if let imageData = imageData {
                        // 지정된 썸네일 없고 앨범에 이미지 있음
                        diaryDayModel = DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: imageData)
                    } else {
                        // 지정된 썸네일 없고 앨범에 이미지 없음
                        diaryDayModel = DiaryDayModel(dayLabel: dayLabelData, dateLabel: dateLabelData, image: UIImage(named: "diaryDaysDefault"))
                    }
                })
                .disposed(by: self.disposeBag)
        }
        
        return diaryDayModel
    }
    
    func fetchRandomImage(day: Int) -> Observable<UIImage?> {
        var targetImage: UIImage?
        var urls: [String] = []
        self.diary.diaryPages[day-1].pages.forEach { page in // 해당 일차의 페이지
            page.items.forEach { item in // 각 페이지의 아이템
                if item.itemType == .image {
                    urls.append(item.contents[0])
                }
            }
            
            if let url = urls.randomElement() {
                if let image = ImageManager.shared.searchImage(urlString: url) {
                    targetImage = image
                } else {
                    FirebaseStorageManager.downloadImage(urlString: url) { result in
                        ImageManager.shared.cacheImage(urlString: url, image: result ?? UIImage())
                        targetImage = result
                    }
                }
            } else {
                targetImage = nil
            }
        }
        return Observable<UIImage?>.just(targetImage)
    }
    
    private func checkThumbnailValid(url: String?) -> Bool{
        return (url == nil || url == "NoURL") ? false : true
    }
    
    func updateTumbnail(urlString: String, selectedDay: Int, completion: @escaping (Diary) -> Void) {
        let firebaseClient = FirebaseClient()
        
        var thumbnails = self.diary.pageThumbnails
        thumbnails[selectedDay-1] = urlString
        self.diary.pageThumbnails = thumbnails
        
        firebaseClient.updatePageThumbnail(diary: self.diary)
        completion(self.diary)
    }
}
