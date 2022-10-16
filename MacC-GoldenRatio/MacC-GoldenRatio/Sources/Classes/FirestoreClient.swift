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
//        var returnVal: Bool!
        let query = db.collection("User").whereField("userUID", isEqualTo: uid)
        query.getDocuments { querySnapshot, error in
            if querySnapshot?.documents == [] {
                print(querySnapshot?.documents)
                print(123)
                completion(false)
            }else{
                print(querySnapshot?.documents)
                print(456)
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
}
