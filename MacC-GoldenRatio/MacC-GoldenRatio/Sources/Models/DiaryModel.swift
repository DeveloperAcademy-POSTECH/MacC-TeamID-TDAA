//
//  DiaryModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import Foundation

struct Diary: Codable {
	let diaryUUID: String
	let diaryName: String
	let diaryLocation: Location
	let diaryStartDate: String
	let diaryEndDate: String
	let userUIDs: [String]
    var diaryPages: [Pages]
    var pageThumbnails: [String] = []
}

struct Location: Codable {
	let locationName: String
	let locationAddress: String
	let locationCoordinate: [Double]
}

struct Pages: Codable {
    var pages: [Page]
}

struct Page: Codable {
	let pageUUID: String
	var items: [Item]
}

struct Item: Codable {
	let itemUUID: String
	let itemType: ItemType
	var contents: [String]
    /// 상위 뷰의 좌표 시스템에서 Sticker의 위치 좌표, 그리고 크기를 나타냅니다.
	var itemFrame: [Double]
    /// Sticker 자체 좌표 시스템에서의 위치 좌표, 그리고 크기를 나타냅니다.
    var itemBounds: [Double]
    /// Sticker의 크기, 회전각을 나타냅니다.
	var itemTransform: [Double]
}

struct TextBox: Codable {
	let text: String
	let fontName: String
	let fontColor: String
}

struct Image: Codable {
	let imageURL: String
}

struct Sticker: Codable {
	let stickerName: String
}

enum ItemType: String, Codable {
	case text
	case image
	case sticker
	case location
}
