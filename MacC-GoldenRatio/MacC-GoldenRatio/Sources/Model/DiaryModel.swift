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
    var diaryCoverImage: String?
    var userUIDs: [String] = []
    var diaryPages: [Pages] = []
    var pageThumbnails: [String?] = []
}

struct Location: Codable {
    let locationName: String
    let locationAddress: String
    let locationCoordinate: [Double]
    let locationCategory: String?
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
    // location -> [이름, 주소, 위도, 경도]
    // image -> [이미지 URL]
    // sticker -> [Asset 이름]
    
    /// 상위 뷰의 좌표 시스템에서 Sticker의 위치 좌표, 그리고 크기를 나타냅니다.
    var itemFrame: [Double]
    /// Sticker 자체 좌표 시스템에서의 위치 좌표, 그리고 크기를 나타냅니다.
    var itemBounds: [Double]
    /// Sticker의 크기, 회전각을 나타냅니다.
    var itemTransform: [Double]
}

extension Item {
    
    func fetchFrame() -> CGRect {
        let x = self.itemFrame[0]
        let y = self.itemFrame[1]
        let width = self.itemFrame[2]
        let height = self.itemFrame[3]

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func fetchBounds() -> CGRect {
        let x = self.itemBounds[0]
        let y = self.itemBounds[1]
        let width = self.itemBounds[2]
        let height = self.itemBounds[3]

        return CGRect(x: x, y: y, width: width, height: height)
    }
    
    func fetchTransform() -> CGAffineTransform {
        let a = self.itemTransform[0]
        let b = self.itemTransform[1]
        let c = self.itemTransform[2]
        let d = self.itemTransform[3]
        let tx = self.itemTransform[4]
        let ty = self.itemTransform[5]

        return CGAffineTransform(a: a, b: b, c: c, d: d, tx: tx, ty: ty)
    }
    
    func fetchContents() -> [String] {
        let contents = self.contents

        return contents
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
