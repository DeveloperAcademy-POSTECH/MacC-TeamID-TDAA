//
//  MyDiariesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import Combine
import FirebaseFirestore
import UIKit

// TODO: 수정 예정
class MyDiariesViewModel {
	private var client = FirestoreClient()
	
//	let diary = Diary(diaryUUID: "diaryUUID2", diaryName: "포항항", diaryLocation: Location(locationName: "포항영일대", locationAddress: "포항영일대주소", locationCoordinate: [36.020107332983, 129.32530987999]), diaryStartDate: "2022년 10월 4일", diaryEndDate: "2022년 10월 4일", diaryPages: [Page(pageUUID: "PageUUID", items: [Item(itemUUID: "ItemUUID", itemType: .text, contents: ["text"], itemSize: [50, 50], itemPosition: [50, 50, 50], itemAngle: 0)])], userUIDs: ["userUID"])
	
	init() {
		let diaryResult = client.fetchMyDiary("diaryUUID2")
		
		let diaryValue = diaryResult
			.compactMap { data -> Diary? in
				guard case .success(let value) = data else {
					return nil
				}
				return value
			}
		
		let diaryError = diaryResult
			.compactMap { data -> String? in
				guard case .failure(let error) = data else {
					return nil
				}
				return error.localizedDescription
			}
		
		
		
	}
}
