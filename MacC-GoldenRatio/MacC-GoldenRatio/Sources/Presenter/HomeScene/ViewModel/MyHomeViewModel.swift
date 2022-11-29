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
	
	let longPressedEnabled = BehaviorRelay(value: false)
	let filterButtonTapped = BehaviorRelay(value: true)
	
	let diaryCollectionViewModel = DiaryCollectionViewModel()
	let albumCollectionViewModel = AlbumCollectionViewModel()
	
	var isEqual = false
	
	init() {
		createCell()
		
		longPressedEnabled
			.bind(to: diaryCollectionViewModel.longPressedEnabled)
			.disposed(by: disposeBag)
	}
	
	func createCell() {
		let userUID = Observable.just(Auth.auth().currentUser?.uid ?? "")
		
		let diaryResult = userUID
			.flatMapLatest(client.fetchMyDiaries)
			.share()
		
		diaryResult
			.map(getDiaryValue)
			.map(sortDiary)
			.bind(to: diaryCollectionViewModel.collectionDiaryData)
			.disposed(by: disposeBag)
		
		filterButtonTapped
			.asObservable()
			.bind { _ in
				diaryResult
					.map(self.getDiaryValue)
					.map(self.sortDiary)
					.bind(to: self.diaryCollectionViewModel.collectionDiaryData)
					.disposed(by: self.disposeBag)
			}
			.disposed(by: disposeBag)
	}
	
	func getDiaryValue(_ result: Result<[Diary], Error>) -> [Diary] {
		guard case .success(let value) = result else {
			return []
		}
		return value
	}
	
	func sortDiary(_ diaries: [Diary]) -> [Diary] {
		return diaries.sorted { first, second in
			if self.filterButtonTapped.value {
				return first.diaryStartDate.toDate() ?? Date() > second.diaryStartDate.toDate() ?? Date()
			} else {
				return first.diaryName < second.diaryName
			}
		}
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
