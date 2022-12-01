//
//  Layout.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/30.
//

import UIKit

struct Layout {
	// MARK: MyHomeView
	static let tabBarTitleLabelLeading: Int = 20
	static let tabBarTitleLabelTop: Int = 30
	static let addDiaryButtonSize: CGFloat = 50
	static let addDiaryButtonPadding: Int = 20
	
	// MARK: DiaryCollectionView
	static let diaryCollectionViewCellSize: CGSize = CGSize(width: (UIScreen.main.bounds.size.width-60)/2+20, height: ((UIScreen.main.bounds.size.width-60)/2)*1.2121+10)
	static let diaryCollectionViewCellHeaderWidthPadding: CGFloat = 40
	static let diaryCollectionViewCellHeaderHeight: CGFloat = 30
	static let diaryCollectionViewCellHeaderTop: CGFloat = 30
	static let diaryCollectionViewCellTop: CGFloat = 30
	static let diaryCollectionViewCellLeading: CGFloat = 20
	static let diaryCollectionViewCellTrailing: CGFloat = 20
	static let diaryCollectionViewCellBottom: CGFloat = 20
	static let diaryCollectionViewCellTitleLabelLeading: CGFloat = 20
	static let diaryCollectionViewCellTitleLabelTrailing: CGFloat = 20
	static let diaryCollectionViewCellTitleLabelTop: CGFloat = 25
	
	// MARK: MyPlaceView
	static let mapViewTop: Int = 30
	static let mapViewBottom: Int = 30
	static let annotationSize: CGSize = CGSize(width: 80, height: 160)
	
	// MARK: Album
	static let myAlbumBackgroundLabelBottom: CGFloat = 330
	
	// MARK: - Sign In
	static let logInButtonSize: CGSize = CGSize(width: 268, height: 50)
	static let logInButtonBottomInset: CGFloat = 80
	static let logInButtonImagePointSize: CGFloat = 17
	
	// MARK: Page
	static let pagePadding: CGFloat = 10
	static let pageToolButtonInterval: CGFloat = 10
	static let pageToolButtonSize: CGSize = CGSize(width: 28, height: 28)
	static let pagePhotoToolButtonSize: CGSize = CGSize(width: 34, height: 28)
	static let pageDocsToolButtonSize: CGSize = CGSize(width: 26, height: 28)
	static let pageToolButtonPointSize: CGFloat = 18
	
	// MARK: PageToolViewController
	static let mapSearchViewSearchBarTopPadding: CGFloat = 20
	static let stickerPickerPadding: CGFloat = 10
	static let stickerPickerButtonFrameSize: CGSize = CGSize(width: 35, height: 35)
	static let stickerPickerButtonPointSize: CGFloat = 18
	
	// MARK: Sticker
	static let stickerDefaultSize: CGSize = CGSize(width: 100, height: 100)
	static let stickerControllerSize: CGSize = CGSize(width: 22, height: 22)
	static let stickerBorderWidth: CGFloat = 1
	static let stickerBorderInset: CGFloat = 5
	
	// MARK: - Diary Config
	static let diaryConfigCancelButtonLeftInset: CGFloat = 20
	static let diaryConfigDoneButtonRightInset: CGFloat = 20
	static let diaryConfigCollectionViewInset: CGFloat = 40
	static let diaryConfigCollectionViewCellHeight: CGFloat = 86
	static let diaryConfigCollectionViewCellInset: CGFloat = 16
	
	// MARK: - Diary Config Cell
	static let diaryConfigCellTopInset: CGFloat = 10
	static let diaryConfigCellLeftInset: CGFloat = 16
	static let diaryConfigCellBottomInset: CGFloat = 10
	static let diaryConfigCellRightInset: CGFloat = 12
	
	// MARK: - My Diary Pages
	static let myDiaryPagesItemSpacing: CGFloat = 20
	
	// MARK: My Page
	static let myPageHorizontalPadding: CGFloat = 20
	static let myPageHorizontalPadding2: CGFloat = 40
	static let myPageHorizontalSpacing: CGFloat = 10
	static let myPageHorizontalSpacing2: CGFloat = 20
	static let myPageVerticalPadding: CGFloat = 40
	static let myPageVerticalPadding2: CGFloat = 30
	static let myPageVerticalSpacing: CGFloat = 10
	static let myPageVerticalSpacing2: CGFloat = 15
	static let myPageVerticalSpacing3: CGFloat = 50
	static let myPageVerticalSpacing4: CGFloat = 30
	static let myPageButtonHeight: CGFloat = 48
	static let myPageProfileImageSize: CGSize = CGSize(width: 62, height: 62)
	static let myPageStickerImageSize: CGSize = CGSize(width: 50, height: 50)
	static let myPageMenuTableViewHeight: CGFloat = 245
	static let setProfileProfileImageSize: CGSize = CGSize(width: 150, height: 150)
	
	// MARK: - Calendar View
	static let calendarCollectionViewInset: CGFloat = 21
	static let calendarCollectionViewMultiplier: CGFloat = 0.32
	static let calendarHeaderHeight: CGFloat = 80
	static let calendarFooterHeight: CGFloat = 45
	static let calendarCloseButtonTop: CGFloat = 30
	static let calendarCloseButtonSize: CGSize = CGSize(width: 50, height: 50)

	// MARK: - Calendar View Cell
	static let calendarCellMultiplier: CGFloat = 1.2
	static let calendarCellDivider: CGFloat = 1.8
	
	// MARK: - MapSearch Table View Cell
	static let mapSearchTableViewCellHeight: CGFloat = 80
	static let mapSearchTableViewCellVerticalPadding: CGFloat = 10
	static let mapSearchTableViewCellHorizontalPadding: CGFloat = 20
}
