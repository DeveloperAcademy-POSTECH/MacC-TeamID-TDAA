//
//  DiaryConfigViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/13.
//

import FirebaseAuth
import UIKit

class DiaryConfigViewModel {
    private let firebaseClient = FirebaseClient()
    
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
        if checkAvailable() {
            guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = self.endDate, let diaryCover = self.diaryCover, let userUIDs = self.userUIDs else { return print("Upload Error") }
            
            // TODO: - pageCount 처리
            self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, userUIDs: userUIDs)
            
            guard let diary = diary else { return }
            
            firebaseClient.addDiary(diary: diary)
        }
    }
    
    func getDiaryData(diary: Diary) {
        self.diaryUUID = diary.diaryUUID
        self.title = diary.diaryName
        self.location = diary.diaryLocation
        self.startDate = diary.diaryStartDate
        self.endDate = diary.diaryEndDate
        self.diaryCover = diary.diaryCover
        self.userUIDs = diary.userUIDs
        self.diaryPages = diary.diaryPages
        self.thumbnails = diary.pageThumbnails
    }
    
    func setDiaryData() {
        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = self.endDate, let diaryCover = self.diaryCover, let UIDs = self.userUIDs else { return print("Upload Error") }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover, userUIDs: UIDs, diaryPages: self.diaryPages, pageThumbnails: self.thumbnails)
    }
    
    func checkAvailable() -> Bool {
        if let _ = self.title, let _ = self.location, let _ = self.startDate, let _ = self.endDate {
            return true
        } else {
            print("ERROR: Incomplete Value")
            return false
        }
    }
    
    private func getPageCount() -> Int {
        let count: Int
        
        if let startDate = startDate?.toDate(), let endDate = endDate?.toDate() {
            count = Int((endDate).timeIntervalSince(startDate)) / 86400
        } else {
            count = 1
        }
        
        return count
    }
}
