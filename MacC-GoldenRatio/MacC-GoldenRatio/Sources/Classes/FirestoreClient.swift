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
	
	func fetchDiaryMapData(_ uid: String) async throws -> [MapData] {
		var diaries = [Diary]()
		var userImageURL = [String]()
		
		var mapDatas = [MapData]()
		
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
			mapDatas.append(MapData(diaryName: diary.diaryName, diaryCover: diary.diaryCover, location: diary.diaryLocation))
		}

		return mapDatas
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
    
    func setMyUser(myUser: User) {
        do {
            try db.collection("User").document(myUser.userUID).setData(from: myUser)
        } catch {
            print(error)
        }
    }
}
