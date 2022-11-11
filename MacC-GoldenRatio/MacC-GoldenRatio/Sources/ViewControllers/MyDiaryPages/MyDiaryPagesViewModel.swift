//
//  MyDiaryPagesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/13.
//
import FirebaseFirestore
import FirebaseAuth
import UIKit

class MyDiaryPagesViewModel {
    private var db = Firestore.firestore()
    private var myUID = Auth.auth().currentUser?.uid ?? ""
    @Published var thumbnailURL: [String] = []
    @Published var diaryData: Diary = Diary(diaryUUID: "", diaryName: "", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [], locationCategory: nil), diaryStartDate: "", diaryEndDate: "", diaryCover: "")
    
    func diaryDataSetup(_ completion: @escaping () -> Void) {
        Task {
            do {
                self.diaryData = try await getDiaryData(uuid: self.diaryData.diaryUUID)
                completion()
            } catch {
                print(error)
            }
        }
    }
    
    func getDiaryData(uuid diaryUUID: String) async throws -> Diary {
        let query = db.collection("Diary").whereField("diaryUUID", isEqualTo: diaryUUID)
        let documents = try await query.getDocuments()
        let data = try documents.documents[0].data(as: Diary.self)
        
        return data
    }
    
    func getThumbnailURL() async throws {
        Task {
            do {
                self.thumbnailURL = try await getDiaryData(uuid: self.diaryData.diaryUUID).pageThumbnails
            } catch {
                print(error)
            }
        }
    }
    
    func outCurrentDiary(diary: Diary) {
        // 다이어리 UID에서 자신 삭제
        let userUIDs = diary.userUIDs.filter(){ $0 != myUID }
        let diaryRef = db.collection("Diary").document(diary.diaryUUID)

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
	
	func makeDateString(diary: Diary, page: Int) -> String {
		guard let startDate = diary.diaryStartDate.toDate() else { return "" }
		guard let currentDate = Calendar.current.date(byAdding: .day, value: page - 1, to: startDate) else { return "" }
		let labelDayOfWeek = currentDate.dayOfTheWeek()
		
		return "\(currentDate.customFormat()) (\(labelDayOfWeek))"
	}
}
