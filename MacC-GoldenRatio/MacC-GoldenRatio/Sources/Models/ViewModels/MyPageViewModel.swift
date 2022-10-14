//
//  MyPageViewModel.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/14.
//
import FirebaseAuth
import UIKit

class MyPageViewModel {
    private var myUID: String = Auth.auth().currentUser?.uid ?? ""
    @Published var myUser: User = User(userUID: "", userName: "", userImageURL: "", diaryUUIDs: [""])
    @Published var myProfileImage: UIImage = UIImage()
    let menuArray = ["앱 버전", "오픈소스", "앱 평가하기", "로그아웃", "회원탈퇴"]
    
    init() {
        Task{
            do {
                await self.myUser = try FirestoreClient().fetchMyUser(myUID)
                try await fetchImage()
            }catch{
                print(error)
            }
        }
    }
    private func fetchImage() async throws {
        let url = myUser.userImageURL
        guard var image = ImageManager.shared.searchImage(url: url) else {
            FirebaseStorageManager.downloadImage(urlString: url) { result in
                self.myProfileImage = result ?? UIImage()
                ImageManager.shared.cacheImage(url: url, image: self.myProfileImage)
            }
            return
        }
        myProfileImage = image
    }
}
