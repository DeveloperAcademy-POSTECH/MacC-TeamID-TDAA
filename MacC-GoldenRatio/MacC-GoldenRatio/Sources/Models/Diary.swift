//
//  DiaryModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import Foundation

struct DiaryResponse: Codable {
	let documents: [Document]
}

struct Document: Codable {
	let name: String
	let diaries: Diary
	let createTime, updateTime: String
}

struct Diary: Codable {
	let diaryLocation: DiaryLocation
	let diaryPages: [DiaryPages]
	let userUIDs: [String]
	let diaryStartDate, diaryEndDate, diaryUUID, diaryName: String
	
	private enum RootKey: String, CodingKey {
		case fields
	}
	
	private enum FieldKey: String, CodingKey {
		case diaryLocation
		case diaryPages
		case userUIDs
		case diaryStartDate, diaryEndDate, diaryUUID, diaryName
	}
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: RootKey.self)
		let fieldContainer = try container.nestedContainer(keyedBy: FieldKey.self, forKey: .fields)
		self.diaryLocation = try fieldContainer.decode(DiaryLocationMapValue.self, forKey: .diaryLocation).mapValue.fields
		self.diaryPages = try fieldContainer.decode(DiaryPagesArrayValue.self, forKey: .diaryPages).arrayValue.values.map { $0.mapValue }.map { $0.fields }
		self.userUIDs = try fieldContainer.decode(StringArray.self, forKey: .userUIDs).arrayValue.values.map { $0.stringValue }
		self.diaryStartDate = try fieldContainer.decode(StringValue.self, forKey: .diaryStartDate).stringValue
		self.diaryEndDate = try fieldContainer.decode(StringValue.self, forKey: .diaryEndDate).stringValue
		self.diaryUUID = try fieldContainer.decode(StringValue.self, forKey: .diaryUUID).stringValue
		self.diaryName = try fieldContainer.decode(StringValue.self, forKey: .diaryName).stringValue
	}
}

struct StringValue: Codable {
	let stringValue: String
}

struct DiaryLocationMapValue: Codable {
	let mapValue: DiaryLocationMapFields
}

struct DiaryLocationMapFields: Codable {
	let fields: DiaryLocation
}

struct DiaryLocation: Codable {
	let locationCoordinate: [Double]
	let locationAddress, locationName: String
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.locationCoordinate = try container.decode(DoubleArrayValue.self, forKey: .locationCoordinate).arrayValue.values.map { $0.doubleValue }
		self.locationAddress = try container.decode(StringValue.self, forKey: .locationAddress).stringValue
		self.locationName = try container.decode(StringValue.self, forKey: .locationName).stringValue
	}
}

struct DoubleArrayValue: Codable {
	let arrayValue: DoubleValues
}

struct DoubleValues: Codable {
	let values: [DoubleValue]
}

struct DoubleValue: Codable {
	let doubleValue: Double
}

struct DiaryPagesArrayValue: Codable {
	let arrayValue: DiaryPagesValues
}

struct DiaryPagesValues: Codable {
	let values: [DiaryPagesMapValue]
}

struct DiaryPagesMapValue: Codable {
	let mapValue: DiaryPagesFields
}

struct DiaryPagesFields: Codable {
	let fields: DiaryPages
}

struct DiaryPages: Codable {
	let items: [Item]
	let pageUUID: String
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.items = try container.decode(ItemsArrayValue.self, forKey: .items).arrayValue.values.map { $0.mapValue }.map { $0.fields }
		self.pageUUID = try container.decode(StringValue.self, forKey: .pageUUID).stringValue
	}
}

struct ItemsArrayValue: Codable {
	let arrayValue: ItemsValues
}

struct ItemsValues: Codable {
	let values: [ItemsMapValue]
}

struct ItemsMapValue: Codable {
	let mapValue: ItemsFields
}

struct ItemsFields: Codable {
	let fields: Item
}

struct Item: Codable {
	let itemUUID: String
	let contents: [String]
	let itemType: String
	let itemTransform, itemBounds: [Double]
	
	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.itemUUID = try container.decode(StringValue.self, forKey: .itemUUID).stringValue
		self.contents = try container.decode(StringArray.self, forKey: .contents).arrayValue.values.map { $0.stringValue }
		self.itemType = try container.decode(StringValue.self, forKey: .itemType).stringValue
		self.itemTransform = try container.decode(DoubleArrayValue.self, forKey: .itemTransform).arrayValue.values.map { $0.doubleValue }
		self.itemBounds = try container.decode(DoubleArrayValue.self, forKey: .itemBounds).arrayValue.values.map { $0.doubleValue }
	}
}

struct StringArray: Codable {
	let arrayValue: StringValues
}

struct StringValues: Codable {
	let values: [StringValue]
}
