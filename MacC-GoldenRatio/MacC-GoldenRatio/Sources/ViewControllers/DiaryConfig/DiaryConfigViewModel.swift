//
//  DiaryConfigViewModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/10/13.
//

import UIKit

class DiaryConfigViewModel {
    private let firebaseClient = FirebaseClient()
    
    var diaryUUID: String?
    var title: String?
    var location: Location?
    var startDate: String?
    var endDate: String?
    var diary: Diary?
    
    func addDiary() {
        diaryUUID = UUID().uuidString + String(Date().timeIntervalSince1970)
        let diaryCoverArray = ["Black", "Blue", "Brown", "Green", "Orange", "Pink", "Purple", "Red", "White", "Yellow"]
        let diaryCover = "diary\(diaryCoverArray[Int.random(in: 0...9)])"

        guard let diaryUUID = self.diaryUUID, let title = self.title, let location = self.location, let startDate = self.startDate, let endDate = endDate else { return print("Upload Error") }
        
        self.diary = Diary(diaryUUID: diaryUUID, diaryName: title, diaryLocation: location, diaryStartDate: startDate, diaryEndDate: endDate, diaryCover: diaryCover)
        
        guard let diary = diary else { return }
        
        firebaseClient.addDiary(diary: diary)
    }
    
    func updateDiary() {
        print("Update Diary")
    }
    
    func getDiaryData(diary: Diary) {
        self.diaryUUID = diary.diaryUUID
        self.title = diary.diaryName
        self.location = diary.diaryLocation
        self.startDate = diary.diaryStartDate
        self.endDate = diary.diaryEndDate
    }
    
    func checkAvailable() -> Bool {
        if let _ = self.title, let _ = self.location, let _ = self.startDate, let _ = self.endDate {
            return true
        } else {
            print("ERROR: Incomplete Value")
            return false
        }
    }
}
