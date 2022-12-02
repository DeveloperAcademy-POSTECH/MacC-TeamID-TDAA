//
//  DiaryConfigModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/04.
//

import FirebaseAuth
import Foundation

struct DiaryConfigModel {
    // TODO: Config Model Setting
}

enum ConfigState {
    case create
    case modify
    
    var identifier: String {
        switch self {
        case .create:
            return "LzCreate".localized
        case .modify:
            return "LzModify".localized
        }
    }
    
    var alertMessage: String {
        switch self {
        case .create:
            return "LzDiaryConfigCreate".localized
        case .modify:
            return "LzDiaryConfigModify".localized
        }
    }
}

enum ConfigContentType: CaseIterable {
    case diaryName
    case location
    case diaryDate
    case diaryColor
    case diaryImage
    
    var title: String {
        switch self {
        case .diaryName:
            return "LzDiaryConfigDiaryName".localized
        case .location:
            return "LzDiaryConfigDiaryLocation".localized
        case .diaryDate:
            return "LzDiaryConfigDiaryDate".localized
        case .diaryColor:
            return "LzDiaryConfigDiaryColor".localized
        case .diaryImage:
            return "LzDiaryConfigDiaryImage".localized
        }
    }
}
