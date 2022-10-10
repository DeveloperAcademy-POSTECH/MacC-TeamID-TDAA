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
	var diaryPages: [Page]
	let userUIDs: [String]
}

struct Location: Codable {
	let locationName: String
	let locationAddress: String
	let locationCoordinate: [Double]
}

struct Page: Codable {
	let pageUUID: String
	var items: [Item]
}

struct Item: Codable {
	let itemUUID: String
	let itemType: ItemType
	var contents: [String]
	var itemFrame: [Double]
    var itemBounds: [Double]
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
