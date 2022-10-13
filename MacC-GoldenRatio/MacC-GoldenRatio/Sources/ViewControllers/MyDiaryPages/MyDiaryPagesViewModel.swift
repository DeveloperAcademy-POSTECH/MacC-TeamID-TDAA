//
//  MyDiaryPagesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/13.
//

import FirebaseFirestore
import FirebaseAuth
import UIKit

class MyDiaryPagesViewModel {
    private var db = Firestore.firestore()
    var imageURL: String = ""
    var myUID = Auth.auth().currentUser?.uid ?? ""
    
    func getDiaryData(uuid diaryUUID: String) async throws -> Diary? {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        
        return data
    }
    
    func outCurrentDiary(diary: Diary) {
        // 다이어리 UID에서 자신 삭제
        // getDiaryData(diary: diary)
        let userUIDs = diary.userUIDs.filter(){ $0 != myUID }
        let diaryRef = db.collection("Diary").document(diary.diaryUUID)
        

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
    
    func getThumbnailImages() {
        
    }
}
