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
    let complete: Driver<Void>
    let textfieldEndEdit: Signal<Void>
    
    // View -> ViewModel
    let doneButtonTapped = PublishRelay<Void>()
    let cancelButtonTapped = PublishRelay<Void>()
    var diaryTitle = PublishRelay<String?>()
    let diaryCoverImage = ReplayRelay<UIImage>.create(bufferSize: 1)
    
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
    var coverImage: UIImage? = UIImage()
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
            self.coverImageURL = diary.diaryCoverImage
            self.userUIDs = diary.userUIDs
            self.diaryPages = diary.diaryPages
            self.thumbnails = diary.pageThumbnails
            self.configState = .modify
        } else {
            self.configState = .create
            self.diaryUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
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
            self.diaryCoverImage.accept((UIImage(named: "selectImage") ?? UIImage()))
        case .modify:
            self.cellData = Observable
                .combineLatest(titleCell, locationCell, colorCell, imageCell) { [$0, $1, $2, $3] }
                .asDriver(onErrorJustReturn: [])
            if let coverImageURL = self.coverImageURL {
                if let image = ImageManager.shared.searchImage(urlString: coverImageURL) {
                    self.diaryCoverImage.accept(image)
                } else {
                    let diaryCoverImage = self.diaryCoverImage
                    FirebaseStorageManager.downloadImage(urlString: coverImageURL) { image in
                        diaryCoverImage.accept(image ?? (UIImage(named: "selectImage") ?? UIImage()))
                    }
                }
            } else {
                diaryCoverImage.accept((UIImage(named: "selectImage") ?? UIImage()))
                print("diary Cover Image download Failed")
            }
            
        }
        
        self.presentAlert = cancelButtonTapped
            .map { _ in Void() }
            .asSignal(onErrorSignalWith: .empty())
        
        self.complete = doneButtonTapped
            .map { _ in Void() }
            .asDriver(onErrorDriveWith: .empty())
        
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
            .subscribe(onNext: {
                let colorViewModel = $0.diaryColorViewModel
                if let fisrtIndex = colorViewModel.colors.firstIndex(of: diary?.diaryCover ?? "") {
                    colorViewModel.itemSelected.onNext(fisrtIndex)
                }
                colorViewModel.itemSelected
                    .subscribe(onNext: { index in
                        self.diaryCover = "\(self.diaryColorViewModel.colors[index])"
                    })
                    .disposed(by: self.disposeBag)
            })
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
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = endDate, let diaryCover = diaryCover else { return print("Check Data") }
        
        for _ in 1...getPageCount() {
            thumbnails.append("NoURL")
            let pageUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
            let pages = [Page(pageUUID: pageUUID, items: [])]
            diaryPages.append(Pages(pages: pages))
        }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, diaryCoverImage: self.coverImageURL, userUIDs: [self.myUID], diaryPages: self.diaryPages, pageThumbnails: self.thumbnails)
        
        guard let diary = diary else { return }
        
        firebaseClient.addDiary(diary: diary)
    }
    
    func updateDiary(_ completion: @escaping () -> Void) {
        setDiaryData()
        guard let diary = diary else { return }
        firebaseClient.addDiary(diary: diary)
        completion()
    }
    
    func setDiaryData() {
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = self.endDate, let diaryCover = self.diaryCover, let UIDs = self.userUIDs else { return print("If in Modify: Diary Set Error") }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, diaryCoverImage: self.coverImageURL, userUIDs: UIDs, diaryPages: self.diaryPages, pageThumbnails: self.thumbnails)
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
    
    func uploadImage(_ completion: @escaping () -> Void) {
        if let coverImage = self.coverImage {
            FirebaseStorageManager.uploadImage(image: coverImage, pathRoot: "Diary/" + self.diaryUUID! + "/diaryCoverImage") { url in
                guard let url = url else { return }
                self.coverImageURL = url.absoluteString
                ImageManager.shared.cacheImage(urlString: url.absoluteString, image: coverImage)
                completion()
            }
        } else {
            self.coverImageURL = nil
            print("ERROR: No Diary to uplaod image")
            completion()
        }
    }
    
    func downLoadImage(urlString: String) {
        guard let image = ImageManager.shared.searchImage(urlString: urlString) else {
            FirebaseStorageManager.downloadImage(urlString: urlString) { image in
                self.diaryCoverImage.accept(image ?? (UIImage(named: "selectImage") ?? UIImage()))
                self.coverImage = image
            }
            return
        }
        self.diaryCoverImage.accept(image)
        self.coverImage = image
    }
    
    func resetCoverImage() {
        self.diaryCoverImage.accept((UIImage(named: "selectImage") ?? UIImage()))
        self.coverImage = nil
    }
}
