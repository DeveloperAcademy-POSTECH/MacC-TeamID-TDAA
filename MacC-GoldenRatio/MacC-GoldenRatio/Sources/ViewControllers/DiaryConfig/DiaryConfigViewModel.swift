//
//  DiaryConfigViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/13.
//

import FirebaseAuth
import RxSwift
import RxCocoa
import UIKit

class DiaryConfigViewModel {
    private let disposeBag = DisposeBag()
    private let firebaseClient = FirebaseClient()
    let titleCellViewModel = DiaryConfigCellViewModel(type: .diaryName)
    let locationCellViewModel = DiaryConfigCellViewModel(type: .location)
    let dateCellViewModel = DiaryConfigCellViewModel(type: .diaryDate)
    var diaryConfigModel = DiaryConfigModel()
    
    // ViewModel -> View
    let cellData: Driver<[DiaryConfigCellViewModel]>
    let presentAlert: Signal<Void>
    let complete: Signal<Void>
    let textfieldEndEdit: Signal<Void>
    
    // View -> ViewModel
    let doneButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    var diaryTitle = PublishRelay<String?>()
    
    // Model Observer
    let diaryData = PublishRelay<Diary>()
    
    // TODO: Model 관련 프로퍼티 / 메소드 분리
    var diaryUUID: String?
    var title: String?
    var location: Location?
    var startDate: String?
    var endDate: String?
    var diaryCover: String?
    var userUIDs: [String]?
    var diaryPages: [Pages] = []
    var thumbnails: [String] = []
    var myUID = Auth.auth().currentUser?.uid ?? ""
    
    var pageArray: [Page] = []
    var diary: Diary?
    let configState: ConfigState
    
    init(diary: Diary?) {
        
        if let diary = diary {
            self.diary = diary
            self.configState = .modify
        } else {
            self.configState = .create
        }

        let titleCell = Observable<DiaryConfigCellViewModel>.just(titleCellViewModel)
        let locationCell = Observable<DiaryConfigCellViewModel>.just(locationCellViewModel)
        let dateCell = Observable<DiaryConfigCellViewModel>.just(dateCellViewModel)
        
        switch self.configState {
        case .create:
            self.cellData = Observable
                .combineLatest(titleCell, locationCell, dateCell) { [$0, $1, $2] }
                .asDriver(onErrorJustReturn: [])
            
        case .modify:
            self.cellData = Observable
                .combineLatest(titleCell, locationCell) { [$0, $1] }
                .asDriver(onErrorJustReturn: [])
        }
        
        self.presentAlert = cancelButtonTapped
            .map { _ in Void() }
            .asSignal(onErrorSignalWith: .empty())
        
        self.complete = doneButtonTapped
            .map { _ in Void() }
            .asSignal(onErrorSignalWith: .empty())
        
        self.textfieldEndEdit = doneButtonTapped
            .map { _ in Void() }
            .asSignal(onErrorSignalWith: .empty())
        
        titleCell
            .subscribe(onNext: { self.diaryTitle = $0.textFieldText })
            .disposed(by: disposeBag)
        
        self.diaryTitle
            .startWith(diary?.diaryName)
            .subscribe(onNext: { self.title = $0 })
            .disposed(by: disposeBag)
        
        [titleCellViewModel, locationCellViewModel, dateCellViewModel].forEach { viewModel in
            viewModel.diary = self.diary
        }

    }
    
    func addDiary() {
        diaryUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let diaryCoverArray = ["Black", "Blue", "Brown", "Green", "Orange", "Pink", "Purple", "Red", "White", "Yellow"]
        let diaryCover = "diary\(diaryCoverArray[Int.random(in: 0...9)])"
        
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = endDate else { return print("Upload Error") }
        
        for _ in 1...getPageCount() {
            thumbnails.append("NoURL")
            let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
            let pages = [Page(pageUUID: pageUUID, items: [])]
            diaryPages.append(Pages(pages: pages))
        }

        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, userUIDs: [myUID], diaryPages: diaryPages, pageThumbnails: thumbnails)
        
        guard let diary = diary else { return }

        firebaseClient.addDiary(diary: diary)
    }
    
    func updateDiary() {
        
        setDiaryData()
        
        guard let diary = diary else { return }
        firebaseClient.addDiary(diary: diary)
    }
    
    func getDiaryData(diary: Diary?) {
        self.diaryUUID = diary?.diaryUUID
        // self.title = diary?.diaryName
        self.location = diary?.diaryLocation
        self.startDate = diary?.diaryStartDate
        self.endDate = diary?.diaryEndDate
        self.diaryCover = diary?.diaryCover
        self.userUIDs = diary?.userUIDs
        self.diaryPages = diary?.diaryPages ?? []
        self.thumbnails = diary?.pageThumbnails ?? []
    }
    
    func setDiaryData() {
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = self.endDate, let diaryCover = self.diaryCover, let UIDs = self.userUIDs else { return print("Upload Error") }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, userUIDs: UIDs, diaryPages: self.diaryPages, pageThumbnails: self.thumbnails)
    }
    
    func checkAvailable() -> Bool {
        
        switch configState {
        case .modify:
            getDiaryData(diary: diary)
        case .create:
            break
        }
        
        if let title = self.title, let _ = self.location, let _ = self.startDate, let _ = self.endDate {
            if title.isEmpty {
                return false
            }
            setDiaryData()
            return true
        } else {
            print("ERROR: Incomplete Value")
            return false
        }
    }
    
    private func getPageCount() -> Int {
        let count: Int
        
        if let startDate = startDate?.toDate(), let endDate = endDate?.toDate() {
            count = Int((endDate).timeIntervalSince(startDate)) / 86400 + 1
        } else {
            count = 1
        }
        
        return count
    }
}

