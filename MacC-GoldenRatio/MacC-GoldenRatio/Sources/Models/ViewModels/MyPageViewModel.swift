//
//  MyPageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/14.
//

import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift
import UIKit

class MyPageViewModel {
    private var db = Firestore.firestore()
    static let shared = MyPageViewModel()
    private var myUID: String = Auth.auth().currentUser?.uid ?? ""
    @Published var myUser: User = User(userUID: "", userName: "", userImageURL: "", diaryUUIDs: [""])
    @Published var myProfileImage: UIImage = UIImage()
    @Published var myTravelLocations: [String] = []
    let menuArray: [(String, String?)] = [("앱 버전", "1.0.1"), ("오픈소스",">"), ("앱 평가하기",">"), ("로그아웃", ">"), ("회원탈퇴", ">")]
    
    init() {
        Task{
            do {
                await self.myUser = try FirestoreClient().fetchMyUser(myUID)
                try await fetchTravelLocations()
                try await fetchProfileImage()
            }catch{
                print(error)
            }
        }
    }

    private func fetchProfileImage() async throws {
        let url = myUser.userImageURL
        
        if url == "" {
            self.myProfileImage = UIImage(named: "profileImage")!
            return
        }
        
        guard let image = ImageManager.shared.searchImage(urlString: url) else {
            FirebaseStorageManager.downloadImage(urlString: url) { result in
                self.myProfileImage = result ?? UIImage()
                ImageManager.shared.cacheImage(urlString: url, image: self.myProfileImage)
            }
            return
        }
        myProfileImage = image
    }
    
    private func fetchTravelLocations() async throws {
        let locations = try await FirestoreClient().fetchDiaryLocationData(myUID)
        let sortedLocation = removeDuplicate(locations.map{$0.locationAddress})
        self.myTravelLocations = sortedLocation
    }
    
    private func removeDuplicate (_ array: [String]) -> [String] {
        var removedArray = [String]()
        for i in array {
            if removedArray.contains(i) == false {
                removedArray.append(i)
            }
        }
        return removedArray
    }
    
    func setUserData() {
        FirestoreClient().setMyUser(myUser: myUser, completion: nil)
    }
    
    func setNickName(string: String) {
        self.myUser.userName = string
    }
    
    func setProfileImage(image: UIImage, completion: @escaping () -> Void) {
        FirebaseStorageManager.uploadImage(image: image, pathRoot: "User/" + self.myUser.userUID.description) { url in
            guard let urlString = url?.absoluteString else { return }
            self.myUser.userImageURL = urlString
            self.myProfileImage = image
            ImageManager.shared.cacheImage(urlString: urlString, image: image)
            completion()
        }
    }
    
    func deleteUserDB() {
        Task {
            do {
                let uid = Auth.auth().currentUser?.uid
                let userRef = db.collection("User").document(uid ?? self.myUID)
                let diaries = try await FirestoreClient().fetchDiaries(uid ?? self.myUID)
                
                // 가져온 다이어리 목록에 대해서 다이어리 삭제
                for diary in diaries {
                    let diaryRef = db.collection("Diary").document(diary.diaryUUID)
                    let userUIDs = diary.userUIDs.filter(){ $0 != uid }
                    
                    if !userUIDs.isEmpty {
                        let pagesFieldData = ["userUIDs" : userUIDs]
                        try await diaryRef.updateData(pagesFieldData)
                        print(uid)
                        print(userUIDs)
                    } else {
                        // 자신밖에 없으면 다이어리 삭제
                        diaryRef.delete() { err in
                            if let _ = err {
                                print("ERROR: 다이어리 삭제 실패")
                            } else {
                                // 사용자 삭제
                                userRef.delete() { err in
                                    if let _ = err {
                                        print("ERROR: 사용자 DB 삭제 실패")
                                    } else {
                                        print("사용자 DB 삭제 완료")
                                    }
                                }
                                print("다이어리 삭제 완료")
                            }
                        }
                    }
                    
                }
            } catch {
                print(error)
            }
        }
    }
}
