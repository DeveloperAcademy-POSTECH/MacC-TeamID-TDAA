//
//  MyDiariesViewModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/04.
//
import FirebaseAuth
import FirebaseFirestore
import RxCocoa
import RxSwift

// TODO: 수정 예정
class MyHomeViewModel {
	private let client = FirestoreClient()
	private let db = Firestore.firestore()
	private let disposeBag = DisposeBag()
	
	private var myUID = Auth.auth().currentUser?.uid ?? ""
	
	let diaryCollectionViewModel = DiaryCollectionViewModel()
	let mapViewModel = MapViewModel()
	let albumCollectionViewModel = AlbumCollectionViewModel()
	
	var isEqual = false
	var isInitializing = true {
		didSet {
			if isInitializing {
				LoadingIndicator.showLoading(loadingText: "다이어리를 불러오는 중입니다.")
			} else {
				LoadingIndicator.hideLoading()
			}
		}
	}
	
	init() {
		createCell()
	}
	
	func createCell() {
		let userUID = Observable.just(Auth.auth().currentUser?.uid ?? "")
		
		let diaryResult = userUID
			.flatMapLatest(client.fetchMyDiaries)
			.share()
		
		diaryResult
			.map(getDiaryValue)
			.bind(to: diaryCollectionViewModel.collectionDiaryData)
			.disposed(by: disposeBag)
	}
	
	func getDiaryValue(_ result: Result<[Diary], Error>) -> [Diary] {
		guard case .success(let value) = result else {
			return []
		}
		return value
	}
	
	func getFirstDiaryData(_ value: [Diary]?) -> Diary {
		guard let value = value else {
			return Diary(diaryUUID: "", diaryName: "", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [], locationCategory: nil), diaryStartDate: "", diaryEndDate: "", diaryCover: "")
		}
		
		return value.first ?? Diary(diaryUUID: "", diaryName: "", diaryLocation: Location(locationName: "", locationAddress: "", locationCoordinate: [], locationCategory: nil), diaryStartDate: "", diaryEndDate: "", diaryCover: "")
	}
	
	func isDiaryCodeEqualTo(_ diaryUUID: String) {
		Task {
			do {
				self.isEqual = try await client.isDiaryCodeEqualTo(diaryUUID)
			} catch {
				print(error)
			}
		}
	}
	
	func updateJoinDiary(_ diaryUUID: String) {
		db.collection("Diary").document(diaryUUID).updateData(["userUIDs": FieldValue.arrayUnion([myUID])])
	}
}
