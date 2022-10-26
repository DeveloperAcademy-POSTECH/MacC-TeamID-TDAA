//
//  FirebaseClient.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//
import FirebaseAuth
import FirebaseFirestore

class FirebaseClient {
	private var db = Firestore.firestore()
	
	func fetchMyDiaries(uid: String) async throws -> [Diary]? {
		let query = db.collection("Diary").whereField("userUIDs", arrayContains: uid)
		var diaries = [Diary]()
		
		let documents = try await query.getDocuments()
		let result = documents.documents.map({ querySnapshot -> Diary? in
			do {
				let res = try querySnapshot.data(as: Diary.self)
				diaries.append(res)
				return res
			} catch {
				print(error)
				return nil
			}
		})
		
		return diaries
	}
	
	func addDiary(diary: Diary) {
		do {
			try db.collection("Diary").document(diary.diaryUUID).setData(from: diary)
		} catch {
			print(error)
		}
	}
    
    func updatePage(diary: Diary) {
        do {
            var encodedPages: [[String:Any]] = []
            for pages in diary.diaryPages {
                let endcodedPage = try Firestore.Encoder().encode(pages)
                encodedPages.append(endcodedPage)
            }
            let pagesFieldData = ["diaryPages":encodedPages]
            let diaryRef = db.collection("Diary").document(diary.diaryUUID)
            diaryRef.updateData(pagesFieldData)
        } catch {
            print(error)
        }
    }
    
    /// 서버 데이터와 로컬 데이터 병합 후 트랜잭션 업로드
    func transactionPage(diaryUUID: String, newPages: Pages) {
        let diaryReference = db.collection("Diary").document(diaryUUID)
        db.runTransaction({ (transaction, errorPointer) -> Any? in
            let diaryDocument: DocumentSnapshot
            do {
                try diaryDocument = transaction.getDocument(diaryReference)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            var oldDiary: Diary!
            do{
                oldDiary = try diaryDocument.data(as: Diary.self)
            }catch{
                print(error)
                return nil
            }
            
            let userID = Auth.auth().currentUser?.uid ?? ""
            var oldItemDic: [String:Item] = [:]
            let oldPages = oldDiary.diaryPages[0]
            oldPages.pages.forEach({ oldPage in
                oldPage.items.forEach {
                    oldItemDic[$0.itemUUID] = $0
                }
            })

            var newPages = newPages
            newPages.pages.enumerated().forEach { (pageIndex, newPage) in
                let newItems = newPage.items.map({ item in
                    guard let oldItem = oldItemDic[item.itemUUID] else { return item }
                    switch oldItem.lastEditor {
                    case userID:
                        return item
                    case nil:
                        return item
                    default:
                        // otherUser
                        return oldItem
                    }
                })
                newPages.pages[pageIndex].items = newItems
            }
            
            var encodedPages: [[String:Any]] = []
            for pages in [newPages] {
                do {
                    let endcodedPage = try Firestore.Encoder().encode(pages)
                    encodedPages.append(endcodedPage)
                }
                catch {
                    print(error)
                }
            }
            let pagesFieldData = ["diaryPages":encodedPages]
            transaction.updateData(pagesFieldData, forDocument: diaryReference)
            
            return nil
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
            } else {
                print("Transaction successfully committed!")
            }
        }
    }
    
    func updatePageThumbnail(diary: Diary) {
        let pagesFieldData = ["pageThumbnails":diary.pageThumbnails]
        let diaryRef = db.collection("Diary").document(diary.diaryUUID)
        diaryRef.updateData(pagesFieldData)
    }

    
    func bindSnapshotListner(diaryUUID: String, completion: @escaping (DocumentSnapshot) -> Void ) {
        
        db.collection("Diary").document(diaryUUID)
            .addSnapshotListener { documentSnapshot, error in

                guard let document = documentSnapshot else {
                    print("Error fetching document: \(error!)")
                    return
                }

                guard !document.metadata.hasPendingWrites else {
                    print("document has pending writes")
                    return
                }
                completion(document)
            }
        
    }
}
