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
	let diaryPages: [Page]
	let userUIDs: [String]
}

struct Location: Codable {
	let locationName: String
	let locationAddress: String
	let locationCoordinate: [Double]
}

struct Page: Codable {
	let pageUUID: String
	let items: [Item]
}

struct Item: Codable {
	let itemUUID: String
	let itemType: ItemType
	let contents: [String]
	let itemSize: [Double]
	let itemPosition: [Double]
	let itemAngle: Double
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

enum ItemType: Codable {
	case text
	case image
	case sticker
	case location
}
