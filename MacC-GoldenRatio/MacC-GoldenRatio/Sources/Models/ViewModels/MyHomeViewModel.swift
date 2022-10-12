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
	@Published var diaryCellData = [DiaryCell]()
	private let client = FirestoreClient()
	var userUid: String
	
	init(userUid: String) {
		self.userUid = userUid
		fetchLoadData(userUid)
	}
	
	func fetchLoadData(_ uid: String) {
		Task {
			do {
				self.diaryCellData = try await client.fetchDiaryCellData(uid)
			} catch {
				print(error)
			}
		}
	}
}
