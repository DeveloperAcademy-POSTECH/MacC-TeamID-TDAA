//
//  FirebaseClient.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseFirestore

class FirebaseClient {
	private var db = Firestore.firestore()
	
	func fetchMyDiaries(uid: String) async throws -> [Diary]? {
		let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		var diaries = [Diary]()
		
		let documents = try await query.getDocuments()
		let result = documents.documents.map({ querySnapshot -> Diary? in
			do {
				let res = try querySnapshot.data(as: Diary.self)
				diaries.append(res)
				return res
			} catch {
				print(error)
				return nil
			}
		})
		
		return diaries
	}
	
	func addDiary(diary: Diary) {
		do {
			try db.collection("Diary").document(diary.diaryUUID).setData(from: diary)
		} catch {
			print(error)
		}
	}
    
    func updatePage(diary: Diary) {
        do {
            var encodedPages: [[String:Any]] = []
            for page in diary.diaryPages {
                let endcodedPage = try Firestore.Encoder().encode(page)
                encodedPages.append(endcodedPage)
            }
            let pagesFieldData = ["diaryPages":encodedPages]
            let diaryRef = db.collection("Diary").document(diary.diaryUUID)
            diaryRef.updateData(pagesFieldData)
        } catch {
            print(error)
        }
    }
    
    func updatePageThumbnail(diary: Diary) {
        let pagesFieldData = ["pageThumbnails":diary.pageThumbnails]
        let diaryRef = db.collection("Diary").document(diary.diaryUUID)
        diaryRef.updateData(pagesFieldData)
    }

    
    func bindSnapshotListner(diaryUUID: String, completion: @escaping (DocumentSnapshot) -> Void ) {
        
        db.collection("Diary").document(diaryUUID)
            .addSnapshotListener { documentSnapshot, error in
              guard let document = documentSnapshot else {
                print("Error fetching document: \(error!)")
                return
              }
                completion(document)
            }
    }
}
