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
            return "추가"
        case .modify:
            return "수정"
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
            return "다이어리 이름 *"
        case .location:
            return "여행지 *"
        case .diaryDate:
            return "날짜 *"
        case .diaryColor:
            return "다이어리 표지 색상 *"
        case .diaryImage:
            return "대표 이미지"
        }
    }
}

