//
//  MyDiariesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseFirestore
import UIKit

// TODO: 수정 예정
class MyHomeViewModel {
	@Published var diaryData = [Diary]()
	@Published var diaryCellData = [DiaryCell]()
	private let client = FirestoreClient()
	private let db = Firestore.firestore()
	var userUid: String
	
	init(userUid: String) {
		self.userUid = userUid
		fetchLoadData(userUid)
	}
	
	private func fetchLoadData(_ uid: String) {
		Task {
			do {
				self.diaryData = try await client.fetchMyDiaries(uid)
				self.diaryCellData = try await convertDiaryToCellData(diaryData)
			} catch {
				print(error)
			}
		}
	}
	
	private func convertDiaryToCellData(_ diaries: [Diary]) async throws -> [DiaryCell] {
		var diaryCellData = [DiaryCell]()
		var userImageURL = [String]()
		
		for diary in diaries {
			for userUID in diary.userUIDs {
				let query = db.collection("User").whereField("userUID", isEqualTo: userUID)
				let documents = try await query.getDocuments()

				documents.documents.forEach { querySnapshot in
					let data = querySnapshot.data()
					userImageURL.append(data["userImageURL"] as? String ?? "")
				}
			}
			diaryCellData.append(DiaryCell(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, diaryCover: diary.diaryCover, userImageURLs: userImageURL))
			userImageURL.removeAll()
		}

		return diaryCellData
	}
}
