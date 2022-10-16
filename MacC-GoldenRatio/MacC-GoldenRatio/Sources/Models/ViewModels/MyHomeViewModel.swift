//
//  MyDiariesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseFirestore
import FirebaseAuth
import UIKit

// TODO: 수정 예정
class MyHomeViewModel {
	@Published var diaryData = [Diary]()
	@Published var diaryCellData = [DiaryCell]()
	@Published var isInitializing = true {
		didSet {
			if isInitializing {
				LoadingIndicator.showLoading(loadingText: "다이어리를 불러오는 중입니다.")
			} else {
				LoadingIndicator.hideLoading()
			}
		}
	}
	
	private let client = FirestoreClient()
	private let db = Firestore.firestore()
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	var isEqual = false
	
	init() {
		fetchLoadData()
	}
	
	func fetchLoadData() {
		Task {
			do {
				self.isInitializing = true
				diaryData.removeAll()
				self.diaryData = try await client.fetchMyDiaries(myUID)
				self.diaryCellData = try await convertDiaryToCellData(diaryData)
				self.isInitializing = false
			} catch {
				print(error)
			}
		}
	}
	
	func isDiaryCodeEqualTo(_ diaryUUID: String) {
		Task {
			do {
				self.isEqual = try await client.isDiaryCodeEqualTo(diaryUUID)
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
					userImageURL.append(data["userImageURL"] as? String ?? "profileImage")
				}
			}
			diaryCellData.append(DiaryCell(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, diaryCover: diary.diaryCover, userImageURLs: userImageURL))
			userImageURL.removeAll()
		}

		return diaryCellData
	}
	
	func updateJoinDiary(_ diaryUUID: String) {
		db.collection("Diary").document(diaryUUID).updateData(["userUIDs": FieldValue.arrayUnion([myUID])])
	}
}
