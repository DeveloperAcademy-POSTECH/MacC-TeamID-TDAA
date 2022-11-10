//
//  MyDiaryDaysModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import FirebaseFirestore
import RxSwift
import UIKit

struct MyDiaryDaysModel {
    let db = Firestore.firestore()
//    let day: Observable<Int>
//    let date: String
//    let imageURL: String
    
    init() {
        // 다이어리 자체 데이터만 전달하는 역할
    }
    
    func fetchDiaryData(uuid diaryUUID: String) async throws -> Observable<Diary> {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        return Observable.just(data)
    }
    
    func fetchImages() -> Observable<[UIImage]> {
        // 이미지 타입의 item url 처리 후 랜덤 배열 생성해서 뿌리기
        return Observable.just([])
    }
    
    func sendData() -> Observable<[Any]> {
        return Observable.just([])
    }
}
