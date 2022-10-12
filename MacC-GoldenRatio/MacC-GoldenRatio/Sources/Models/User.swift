//
//  UserModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

struct User: Codable {
	let userUID: String
	let userName: String
	let userImageURL: String
	let diaryUUIDs: [String]
}
