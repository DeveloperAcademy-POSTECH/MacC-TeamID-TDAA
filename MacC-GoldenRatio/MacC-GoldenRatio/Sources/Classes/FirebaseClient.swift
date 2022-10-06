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
}
