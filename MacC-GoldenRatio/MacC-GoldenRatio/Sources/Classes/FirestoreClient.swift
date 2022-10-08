//
//  FirebaseClient.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import FirebaseFirestore
import FirebaseFirestoreSwift
import RxCocoa
import RxSwift
import UIKit

enum NetworkError: Error {
	case invalidURL
	case invalidJSON
	case networkError
}

class FirestoreClient {
	private let session: URLSession
	
	init(session: URLSession = .shared) {
		self.session = session
	}
	
	func fetchMyDiary(_ diaryUUID: String) -> Single<Result<Diary, NetworkError>> {
		let url = URL(string: "https://firestore.googleapis.com/v1/projects/macc-goldenratio/databases/(default)/documents/Diary/\(diaryUUID)")!
		
		let request = NSMutableURLRequest(url: url)
		
		return session.rx.data(request: request as URLRequest)
			.map { data in
				do {
					let diaryData = try JSONDecoder().decode(Diary.self, from: data)
					return .success(diaryData)
				} catch {
					return .failure(.invalidJSON)
				}
			}
			.catch { _ in
				.just(.failure(.networkError))
			}
			.asSingle()
	}
	
//	func fetchMyDiaries(_ uid: String) async throws {
//		let (data, _) = try await URLSession.shared.data(for: URLRequest(url: URL(string: "https://firestore.googleapis.com/v1/projects/macc-goldenratio/databases/(default)/documents/Diary")!))
//		let diary = try JSONDecoder().decode(DiaryResponse.self, from: data)
//		print(diary)
//	}
	
	// TODO: 추후 수정 예정
//	func fetchMyDiariesResult(_ uid: String) -> Observable<[Diary]> {
//		return db.collection("Diary").whereField("userUIDs", arrayContains: uid)
//			.add
//	}
	
//	func addDiary(diary: Diary) {
//		do {
//			try db.collection("Diary").document(diary.diaryUUID).setData(from: diary)
//		} catch {
//			print(error)
//		}
//	}
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
