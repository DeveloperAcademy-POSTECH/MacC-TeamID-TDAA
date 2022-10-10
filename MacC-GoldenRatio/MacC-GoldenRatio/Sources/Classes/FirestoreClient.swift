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
//
//	func fetchUserImageURLs(UIDs: [String]) async throws -> [String]? {
//		let query = db.collection("User").whereField("userUID", in: UIDs)
//
//		var userImageURL = [String]()
//
//		let documents = try await query.getDocuments()
//
//		documents.documents.forEach { querySnapshot in
//			let data = querySnapshot.data()
//			userImageURL.append(data["userImageURL"] as? String ?? "")
//		}
//
//		return userImageURL
//	}
}
