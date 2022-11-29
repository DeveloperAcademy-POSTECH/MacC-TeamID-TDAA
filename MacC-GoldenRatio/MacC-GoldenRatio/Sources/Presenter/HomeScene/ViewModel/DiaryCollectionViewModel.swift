//
//  DiaryCollectionViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/29.
//

import FirebaseAuth
import FirebaseFirestore
import RxCocoa
import RxSwift

struct DiaryCollectionViewModel {
	private let db = Firestore.firestore()
	
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	let collectionDiaryData = BehaviorRelay<[Diary]>(value: [])
	let removeData = BehaviorRelay<DiaryCell?>(value: nil)
	let longPressedEnabled = BehaviorRelay(value: false)
	
	func outCurrentDiary(_ diaryUUID: String, _ UIDs: [String]) {
		let userUIDs = UIDs.filter(){ $0 != myUID }
		let diaryRef = db.collection("Diary").document(diaryUUID)
		
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
