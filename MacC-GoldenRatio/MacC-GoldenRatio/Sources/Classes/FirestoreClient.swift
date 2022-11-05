//
//  FirebaseClient.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//

import Firebase
import FirebaseFirestore
import FirebaseFirestoreSwift
import RxSwift
import UIKit

class FirestoreClient {
	private var db = Firestore.firestore()
	
	func fetchDiaries(_ uid: String) async throws -> [Diary] {
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
	
	func fetchMyDiaries(_ uid: String) -> Observable<Result<[Diary], Error>> {
		var diaries = [Diary]()
		return Observable<Result<[Diary], Error>>.create { observer in
			self.db.collection("Diary").whereField("userUIDs", arrayContains: uid).getDocuments { (snapshot, error) in
				if let error = error {
					observer.onError(error)
				}
				snapshot?.documents.forEach { document in
					do {
						diaries.append(try document.data(as: Diary.self))
					} catch {
						observer.onError(error)
					}
				}
				observer.onNext(.success(diaries))
				observer.onCompleted()
			}
			return Disposables.create()
		}
	}
    
    func fetchDiaryLocationData(_ uid: String) async throws -> [Location] {
        var diaries = [Diary]()
        var locations = [Location]()
        
        let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
        
        let querySnapshot = try await query.getDocuments()
        
        querySnapshot.documents.forEach { document in
            do {
                diaries.append(try document.data(as: Diary.self))
            } catch {
                print(error)
            }
        }

        for diary in diaries {
            locations.append(diary.diaryLocation)
        }

        return locations
    }
    
	func fetchDiaryMapData(_ uid: String) async throws -> [MapData] {
		var diaries = [Diary]()
		
		var mapDatas = [MapData]()
		
		let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		
		let querySnapshot = try await query.getDocuments()
		querySnapshot.documents.forEach { document in
			do {
				diaries.append(try document.data(as: Diary.self))
			} catch {
				print(error)
			}
		}

		for diary in diaries {
			mapDatas.append(MapData(diaryName: diary.diaryName, diaryCover: diary.diaryCover, location: diary.diaryLocation))
		}

		return mapDatas
	}
    
    func isExistingUser(_ uid: String, completion: @escaping ((Bool)->Void)){
        let query = db.collection("User").whereField("userUID", isEqualTo: uid)
        query.getDocuments { querySnapshot, error in
            if querySnapshot?.documents == [] {
                completion(false)
            }else{
                completion(true)
            }
        }
    }
    
    func fetchMyUser(_ uid: String) async throws -> User {
        var user: User!
        
        let query = db.collection("User").whereField("userUID", isEqualTo: uid)
        let querySnapshot = try await query.getDocuments()
        
        querySnapshot.documents.forEach { document in
            do {
                user = try document.data(as: User.self)
            } catch {
                print(error)
            }
        }
        return user
    }
    
    func setMyUser(myUser: User, completion: (() -> Void)?) {
        do {
            try db.collection("User").document(myUser.userUID).setData(from: myUser)
            (completion ?? {})()
        } catch {
            print(error)
        }
    }
	
	func fetchDiaryAlbumData(_ uid: String) async throws -> [AlbumData] {
		var diaries = [Diary]()
		var albumDatas = [AlbumData]()
		var imageURLs = [String]()
		
		let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		let querySnapshot = try await query.getDocuments()
		querySnapshot.documents.forEach { document in
			do {
				diaries.append(try document.data(as: Diary.self))
			} catch {
				print(error)
			}
		}

		for diary in diaries {
			for pages in diary.diaryPages {
				for page in pages.pages {
					for item in page.items {
						if item.itemType == .image {
							imageURLs.append(item.contents.first ?? "")
						}
					}
				}
			}
			albumDatas.append(AlbumData(diaryUUID: diary.diaryUUID, diaryName: diary.diaryName, imageURLs: imageURLs, images: nil))
			imageURLs.removeAll()
		}
		return albumDatas
	}
	
	func isDiaryCodeEqualTo(_ diaryUUID: String) async throws -> Bool {
		let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: diaryUUID)
		let querySnapshot = try await query.getDocuments()
		
		return !querySnapshot.documents.isEmpty
	}
}
