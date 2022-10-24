//
//  DiaryModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import Foundation

struct Diary: Codable {
	let diaryUUID: String
	var diaryName: String
	let diaryLocation: Location
	let diaryStartDate: String
	let diaryEndDate: String
	let diaryCover: String
	var userUIDs: [String] = []
    var diaryPages: [Pages] = []
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

struct Item: Codable, Equatable {
	let itemUUID: String
	let itemType: ItemType
	var contents: [String]
    // map -> [이름, 주소, 위도, 경도]
    // image ->
    // sticker ->
    // location ->
    
    /// 상위 뷰의 좌표 시스템에서 Sticker의 위치 좌표, 그리고 크기를 나타냅니다.
	var itemFrame: [Double]
    /// Sticker 자체 좌표 시스템에서의 위치 좌표, 그리고 크기를 나타냅니다.
    var itemBounds: [Double]
    /// Sticker의 크기, 회전각을 나타냅니다.
	var itemTransform: [Double]
    
    static func == (lhs: Item, rhs: Item) -> Bool {
        if lhs.itemUUID != rhs.itemUUID { return false }
        if lhs.itemType != rhs.itemType { return false }
        if lhs.contents != rhs.contents { return false }
        return true
    }
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
