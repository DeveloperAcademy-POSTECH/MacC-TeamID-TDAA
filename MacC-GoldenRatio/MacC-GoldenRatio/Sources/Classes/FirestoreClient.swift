//
//  FirebaseClient.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

class FirestoreClient {
	private var db = Firestore.firestore()
	
	func fetchMyDiaries(_ uid: String) async throws -> [Diary] {
		var diaries = [Diary]()
		
		let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		let querySnapshot = try await query.getDocuments()
		
		querySnapshot.documents.forEach { document in
			do {
				diaries.append(try document.data(as: Diary.self))
			} catch {
				print(error)
			}
		}
		
		return diaries
	}

	func fetchDiaryCellData(_ uid: String) async throws -> [DiaryCell] {
		var diaries = [Diary]()
		var userImageURL = [String]()
		
		var diaryCellData = [DiaryCell]()
		
		var query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		
		let querySnapshot = try await query.getDocuments()
		
		querySnapshot.documents.forEach { document in
			do {
				diaries.append(try document.data(as: Diary.self))
			} catch {
				print(error)
			}
		}

		for diary in diaries {
			for userUID in diary.userUIDs {
				query = db.collection("User").whereField("userUID", isEqualTo: userUID)
				let documents = try await query.getDocuments()

				documents.documents.forEach { querySnapshot in
					let data = querySnapshot.data()
					userImageURL.append(data["userImageURL"] as? String ?? "")
				}
			}
			diaryCellData.append(DiaryCell(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, userImageURLs: userImageURL))
			userImageURL.removeAll()
		}

		return diaryCellData
	}
}
