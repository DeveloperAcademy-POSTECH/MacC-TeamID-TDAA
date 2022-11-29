//
//  UserModel.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//
import FirebaseAuth

struct User: Codable {
	let userUID: String
	var userName: String
	var userImageURL: String
	var diaryUUIDs: [String]
}

struct UserManager {
    static let shared = UserManager()
    
    let userUID = Auth.auth().currentUser?.uid ?? ""
}
