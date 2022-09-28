//
//  DiaryModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import Foundation

struct Diary {
	let diaryUUID: String
	let diaryName: String
	let diaryLocation: Location
	let diaryStartDate: Date
	let diaryEndDate: Date
	let diaryPages: [[Page]]
	let userUIDs: [User]
}

struct Location {
	let locationName: String
	let locationAddress: String
	let locationCoordinate: [Double]
}

struct Page {
	let pageUUID: String
	let items: [Item]
}

struct Item {
	let itemUUID: String
	let itemType: ItemType
	let contents: Any
	let itemSize: [Double]
	let itemPosition: [Double]
	let itemAngle: Double
}

struct TextBox {
	let text: String
	let fontName: String
	let fontColor: String
}

struct Image {
	let imageURL: String
}

struct Sticker {
	let stickerName: String
}

enum ItemType {
	case text
	case image
	case sticker
	case location
}
