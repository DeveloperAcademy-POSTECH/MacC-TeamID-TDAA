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
    var colorCellViewModel = DiaryConfigCellViewModel(type: .diaryColor)
    var imageCellViewModel = DiaryConfigCellViewModel(type: .diaryImage)
    let diaryColorViewModel = DiaryColorCollectionViewModel()
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
    let diaryImage = BehaviorRelay<UIImage>(value: UIImage(named: "selectImage") ?? UIImage())
    
    // TODO: Model 관련 프로퍼티 / 메소드 분리
    // Model Observer
    let diaryData = PublishRelay<Diary>()
    
    var diaryUUID: String?
    var title: String?
    var location: Location?
    var startDate: String?
    var endDate: String?
    var diaryCover: String?
    var userUIDs: [String]?
    var diaryPages: [Pages] = []
    var coverImageURL: String?
    var thumbnails: [String] = []
    var myUID = Auth.auth().currentUser?.uid ?? ""
    
    var pageArray: [Page] = []
    var diary: Diary?
    let configState: ConfigState
    
    init(diary: Diary?) {
        
        if let diary = diary {
            self.diary = diary
            self.diaryUUID = diary.diaryUUID
            self.location = diary.diaryLocation
            self.startDate = diary.diaryStartDate
            self.endDate = diary.diaryEndDate
            self.diaryCover = diary.diaryCover
            self.userUIDs = diary.userUIDs
            self.diaryPages = diary.diaryPages
            self.thumbnails = diary.pageThumbnails
            self.configState = .modify
        } else {
            self.configState = .create
        }

        let titleCell = Observable<DiaryConfigCellViewModel>.just(titleCellViewModel)
        let locationCell = Observable<DiaryConfigCellViewModel>.just(locationCellViewModel)
        let dateCell = Observable<DiaryConfigCellViewModel>.just(dateCellViewModel)
        let colorCell = Observable<DiaryConfigCellViewModel>.just(colorCellViewModel)
        let imageCell = Observable<DiaryConfigCellViewModel>.just(imageCellViewModel)
        
        switch self.configState {
        case .create:
            self.cellData = Observable
                .combineLatest(titleCell, locationCell, dateCell, colorCell, imageCell) { [$0, $1, $2, $3, $4] }
                .asDriver(onErrorJustReturn: [])
            
        case .modify:
            self.cellData = Observable
                .combineLatest(titleCell, locationCell, colorCell, imageCell) { [$0, $1, $2, $3] }
                .asDriver(onErrorJustReturn: [])
            
//            colorCell.subscribe(onNext: { // TODO: 초깃값 설정
//                var colorViewModel = $0.diaryColorViewModel
//                let index = colorViewModel.colors.firstIndex(of: diary?.diaryCover ?? "diaryRed")
//            })
//            .disposed(by: disposeBag)
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
        
        locationCell
            .subscribe(onNext: {
                $0.clearButtonTapped
                    .subscribe( onNext: { _ in self.location = nil })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        dateCell
            .subscribe(onNext: {
                $0.clearButtonTapped
                    .subscribe(onNext: { _ in
                        self.startDate = nil
                        self.endDate = nil
                    })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        colorCell
            .subscribe { configCellVM in
                configCellVM.diaryColorViewModel.itemSelected
                    .subscribe(onNext: { index in
                        let diaryCoverArray = self.diaryColorViewModel.colors
                        self.diaryCover = "\(diaryCoverArray[index])"
                    })
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        self.diaryTitle
            .startWith(diary?.diaryName)
            .subscribe(onNext: {
                self.title = $0
                self.cancelButtonTapped
                    .subscribe(onNext: { _ in self.title = self.diary?.diaryName })
                    .disposed(by: self.disposeBag)
            })
            .disposed(by: disposeBag)
        
        [titleCellViewModel, locationCellViewModel, dateCellViewModel, colorCellViewModel, imageCellViewModel].forEach { viewModel in
            viewModel.diary = self.diary
        }
    }
    
    func addDiary() {
        diaryUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = endDate, let diaryCover = diaryCover else { return print("Upload Error") }
        
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
        if checkAvailable() {
            setDiaryData()
            guard let diary = diary else { return }
            firebaseClient.addDiary(diary: diary)
        } else {
            print("ERROR: Diary Update Failed - Available False")
        }
    }
    
    func setDiaryData() {
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = self.endDate, let diaryCover = self.diaryCover, let UIDs = self.userUIDs else { return print("Upload Error") }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, userUIDs: UIDs, diaryPages: self.diaryPages, pageThumbnails: self.thumbnails)
    }
    
    func checkAvailable() -> Bool {
        if let title = self.title, let _ = self.location, let _ = self.startDate, let _ = self.endDate, let _ = self.diaryCover {
            if title.isEmpty {
                return false
            } else {
                setDiaryData()
                return true
            }
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

