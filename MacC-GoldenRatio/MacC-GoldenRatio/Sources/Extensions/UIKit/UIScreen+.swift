////
////  UIScreen+.swift
////  MacC-GoldenRatio
////
////  Created by woo0 on 2022/09/28.
////
//
//import UIKit
//
//extension UIScreen {
//    static func getDevice() -> DeviceSize {
//        if UIScreen.main.bounds.size.width == 428 {
//            return DeviceSize.iPhone13ProMax
//        } else if UIScreen.main.bounds.size.width == 390 {
//            return DeviceSize.iPhone13
//        } else if UIScreen.main.bounds.size.width == 375 {
//            return DeviceSize.iPhoneMini
//        } else if UIScreen.main.bounds.size.width == 414 {
//            return DeviceSize.iPhone11ProMax
//        } else if UIScreen.main.bounds.size.width == 375 {
//            return DeviceSize.iPhone11
//        } else if UIScreen.main.bounds.size.width == 320 {
//            return DeviceSize.iPhoneSE
//        } else if UIScreen.main.bounds.size.width == 414 {
//            return DeviceSize.iPhone8Plus
//        } else if UIScreen.main.bounds.size.width == 375 {
//            return DeviceSize.iPhone8
//        } else {
//            return DeviceSize.iPhone13
//        }
//    }
//
//    enum DeviceSize {
//        case iPhone13
//        case iPhone13ProMax
//        case iPhoneMini
//        case iPhone11ProMax
//        case iPhone11
//        case iPhone8Plus
//        case iPhone8
//        case iPhoneSE
//
//        // MARK: MyHomeView
//        var TabBarTitleLabelLeading: Int {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var TabBarTitleLabelTop: Int {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var TabBarTitleFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 28) ?? UIFont.systemFont(ofSize: 28)
//            }
//        }
//
//        var MyDiariesViewAddDiaryButtonSize: CGFloat {
//            switch self {
//            default: return 50
//            }
//        }
//
//        var MyDiariesViewAddDiaryButtonPadding: Int {
//            switch self {
//            default: return 20
//            }
//        }
//
//        // MARK: MyDiariesViewCustomModalView
//        var MyDiariesViewCustomModalViewButtonHeight: Int {
//            switch self {
//            default: return 50
//            }
//        }
//
//        var MyDiariesViewCustomModalViewStackWidth: Int {
//            switch self {
//            default: return 150
//            }
//        }
//
//        var MyDiariesViewCustomModalViewStackTrailing: Int {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var MyDiariesViewCustomModalViewStackBottom: Int {
//            switch self {
//            default: return 140
//            }
//        }
//
//        // MARK: DiaryCollectionView
//        var diaryContributerImageViewSize: Int {
//            switch self {
//            default: return 25
//            }
//        }
//
//        var diaryContributerImageViewTrailing: Int {
//            switch self {
//            default: return 13
//            }
//        }
//
//        var diaryContributerImageViewBottom: Int {
//            switch self {
//            default: return 10
//            }
//        }
//
//        var diaryCollectionViewCellSize: CGSize {
//            switch self {
//			default: return CGSize(width: (UIScreen.main.bounds.size.width-60)/2+20, height: ((UIScreen.main.bounds.size.width-60)/2)*1.2121+10)
//            }
//        }
//
//        var diaryCollectionViewCellHeaderWidthPadding: CGFloat {
//            switch self {
//            default: return 40
//            }
//        }
//
//        var diaryCollectionViewCellHeaderHeight: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var diaryCollectionViewCellHeaderTop: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var diaryCollectionViewCellTop: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var diaryCollectionViewCellLeading: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryCollectionViewCellTrailing: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryCollectionViewCellBottom: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryCollectionViewCellTitleLabelLeading: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryCollectionViewCellTitleLabelTrailing: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryCollectionViewCellTitleLabelTop: CGFloat {
//            switch self {
//            default: return 25
//            }
//        }
//
//        var diaryCollectionViewCellTitleLabelFont: UIFont {
//            switch self {
//			default: return UIFont(name: "EF_Diary", size: 20) ?? UIFont.systemFont(ofSize: 20)
//            }
//        }
//
//        // MARK: MyPlaceView
//        var mapViewTop: Int {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var mapViewBottom: Int {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var annotationSize: CGSize {
//            switch self {
//            default: return CGSize(width: 80, height: 160)
//            }
//        }
//
//        var annotationTitleFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 16) ?? UIFont.systemFont(ofSize: 16)
//            }
//        }
//
//        // MARK: Album
//        var myAlbumPhotoPageLabelFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        var myAlbumBackgroundLabelBottom: CGFloat {
//            switch self {
//            default: return 330
//            }
//        }
//
//        // All
//        var collectionBackgoundViewFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//
//        // MARK: - Sign In
//        var logInButtonSize: CGSize {
//            switch self {
//            default: return CGSize(width: 268, height: 50)
//            }
//        }
//
//        var logInButtonBottomInset: CGFloat {
//            switch self {
//            default: return 80
//            }
//        }
//
//        var logInButtonImagePointSize: CGFloat {
//            switch self {
//            default: return 17
//            }
//        }
//
//        var loginButtonFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        // MARK: Page
//        var pagePadding: CGFloat {
//            switch self {
//            default: return CGFloat(10)
//            }
//        }
//
//        var pageToolButtonInterval: CGFloat {
//            switch self {
//            default: return CGFloat(10)
//            }
//        }
//
//        var pageDescriptionLabelFont: UIFont {
//            switch self {
//            default: return UIFont.systemFont(ofSize: 17, weight: .regular)
//            }
//        }
//
//        var pageToolButtonSize: CGSize {
//            switch self {
//            default: return CGSize(width: 28, height: 28)
//            }
//        }
//
//        var pagePhotoToolButtonSize: CGSize {
//            switch self {
//            default: return CGSize(width: 34, height: 28)
//            }
//        }
//
//        var pageDocsToolButtonSize: CGSize {
//            switch self {
//            default: return CGSize(width: 26, height: 28)
//            }
//        }
//
//        var pageToolButtonPointSize: CGFloat {
//            switch self {
//            default: return CGFloat(18)
//            }
//        }
//
//        // MARK: PageToolViewController
//        var mapSearchViewSearchBarTopPadding: CGFloat {
//            switch self {
//            default: return CGFloat(20)
//            }
//        }
//
//        var stickerPickerPadding: CGFloat {
//            switch self {
//            default: return CGFloat(10)
//            }
//        }
//
//        var stickerPickerButtonFrameSize: CGSize {
//            switch self {
//            default: return CGSize(width: 35, height: 35)
//            }
//        }
//
//        var stickerPickerButtonPointSize: CGFloat {
//            switch self {
//            default: return CGFloat(18)
//            }
//        }
//
//        // MARK: Sticker
//        var stickerDefaultSize: CGSize {
//            switch self {
//            default: return CGSize(width: 100, height: 100)
//            }
//        }
//
//        var stickerControllerSize: CGSize {
//            switch self {
//            default: return CGSize(width: 22, height: 22)
//            }
//        }
//
//        var stickerBorderWidth: CGFloat {
//            switch self {
//            default: return CGFloat(1)
//            }
//        }
//
//        var stickerBorderInset: CGFloat {
//            switch self {
//            default: return CGFloat(5)
//
//            }
//        }
//
//        // MARK: - Diary Config
//        var diaryConfigTitleFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
//            }
//        }
//
//        var diaryConfigButtonFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        var diaryConfigCancelButtonLeftInset: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryConfigDoneButtonRightInset: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//
//        var diaryConfigCollectionViewInset: CGFloat {
//            switch self {
//            default: return 40
//            }
//        }
//
//        var diaryConfigCollectionViewCellHeight: CGFloat {
//            switch self {
//            default: return 86
//            }
//        }
//
//        var diaryConfigCollectionViewCellInset: CGFloat {
//            switch self {
//            default: return 16
//            }
//        }
//
//        // MARK: - Diary Config Cell
//        var diaryConfigCellTitleFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        var diaryConfigCellContentFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        var diaryConfigCellTopInset: CGFloat {
//            switch self {
//            default: return 10
//            }
//        }
//
//        var diaryConfigCellLeftInset: CGFloat {
//            switch self {
//            default: return 16
//            }
//        }
//
//        var diaryConfigCellBottomInset: CGFloat {
//            switch self {
//            default: return 10
//            }
//        }
//
//        var diaryConfigCellRightInset: CGFloat {
//            switch self {
//            default: return 12
//            }
//        }
//
//        // MARK: - My Diary Pages
//        var myDiaryPagesItemSpacing: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//        // MARK: - PopUp Modal View
//        var popUpModalFont: UIFont {
//            switch self {
//            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
//            }
//        }
//
//        // MARK: My Page
//        /// 20
//        var myPageHorizontalPadding: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//        /// 40
//        var myPageHorizontalPadding2: CGFloat {
//            switch self {
//            default: return 40
//            }
//        }
//        /// 10
//        var myPageHorizontalSpacing: CGFloat {
//            switch self {
//            default: return 10
//            }
//        }
//        /// 20
//        var myPageHorizontalSpacing2: CGFloat {
//            switch self {
//            default: return 20
//            }
//        }
//        /// 20
//        var myPageVerticalPadding: CGFloat {
//            switch self {
//            default: return 40
//            }
//        }
//
//        /// 30
//        var myPageVerticalPadding2: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//
//        /// 10
//        var myPageVerticalSpacing: CGFloat {
//            switch self {
//            default: return 10
//            }
//        }
//        /// 15
//        var myPageVerticalSpacing2: CGFloat {
//            switch self {
//            default: return 15
//            }
//        }
//        /// 50
//        var myPageVerticalSpacing3: CGFloat {
//            switch self {
//            default: return 50
//            }
//        }
//        /// 30
//        var myPageVerticalSpacing4: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//        var myPageButtonHeight: CGFloat {
//            switch self {
//            default: return 48
//            }
//        }
//        /// 62*62
//        var myPageProfileImageSize: CGSize {
//            switch self {
//            default: return CGSize(width: 62, height: 62)
//            }
//        }
//        /// 50*50
//        var myPageStickerImageSize: CGSize {
//            switch self {
//            default: return CGSize(width: 50, height: 50)
//            }
//        }
//        /// 245
//        var myPageMenuTableViewHeight: CGFloat {
//            switch self {
//            default: return 245
//            }
//        }
//        /// 150*150
//        var setProfileProfileImageSize: CGSize {
//            switch self {
//            default: return CGSize(width: 150, height: 150)
//            }
//        }
//        // MARK: - Calendar View
//        var calendarCollectionViewInset: CGFloat {
//            switch self {
//            default: return 21
//            }
//        }
//
//        var calendarCollectionViewMultiplier: CGFloat {
//            switch self {
//            default: return 0.32
//            }
//        }
//
//        var calendarHeaderHeight: CGFloat {
//            switch self {
//            default: return 80
//            }
//        }
//
//        var calendarFooterHeight: CGFloat {
//            switch self {
//            default: return 45
//            }
//        }
//
//        var calendarCloseButtonTop: CGFloat {
//            switch self {
//            default: return 30
//            }
//        }
//
//        var calendarCloseButtonSize: CGSize {
//            switch self {
//            default: return CGSize(width: 50, height: 50)
//            }
//        }
//
//        // MARK: - Calendar View Cell
//        var calendarCellMultiplier: CGFloat {
//            switch self {
//            default: return 1.2
//            }
//        }
//
//        var calendarCellDivider: CGFloat {
//            switch self {
//            default: return 1.8
//            }
//        }
//
//        var numberLabelFont: UIFont {
//            switch self {
//            default: return UIFont.systemFont(ofSize: 20, weight: .regular)
//            }
//        }
//
//        var calendarTermColor: UIColor {
//            switch self {
//            default: return UIColor(named: "calendarTermColor") ?? .systemGray5
//            }
//        }
//
//        var numberLabelColor: UIColor {
//            switch self {
//            default: return UIColor(named: "calendarTextColor") ?? .black
//            }
//        }
//
//        var numberSubLabelColor: UIColor {
//            switch self {
//            default: return UIColor(named: "calendarSubTextColor") ?? .systemGray3
//            }
//        }
//
//        var calendarButtonColor: UIColor {
//            switch self {
//            default: return UIColor(named: "calendarCheckColor") ?? .systemGray
//            }
//        }
//
//        // MARK: - MapSearch Table View Cell
//        /// 80
//        var mapSearchTableViewCellHeight: CGFloat {
//            switch self {
//            default: return CGFloat(80)
//            }
//        }
//        /// 10
//        var mapSearchTableViewCellVerticalPadding: CGFloat {
//            switch self {
//            default: return CGFloat(10)
//            }
//        }
//        /// 20
//        var mapSearchTableViewCellHorizontalPadding: CGFloat {
//            switch self {
//            default: return CGFloat(20)
//            }
//        }
//    }
//}
