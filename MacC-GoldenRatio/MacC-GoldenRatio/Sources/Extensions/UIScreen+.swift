//
//  UIScreen+.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/28.
//

import UIKit

extension UIScreen {
	static func getDevice() -> DeviceSize {
		if UIScreen.main.bounds.size.width == 428 {
			return DeviceSize.iPhone13ProMax
		} else if UIScreen.main.bounds.size.width == 390 {
			return DeviceSize.iPhone13
		} else if UIScreen.main.bounds.size.width == 375 {
			return DeviceSize.iPhoneMini
		} else if UIScreen.main.bounds.size.width == 414 {
			return DeviceSize.iPhone11ProMax
		} else if UIScreen.main.bounds.size.width == 375 {
			return DeviceSize.iPhone11
		} else if UIScreen.main.bounds.size.width == 320 {
			return DeviceSize.iPhoneSE
		} else if UIScreen.main.bounds.size.width == 414 {
			return DeviceSize.iPhone8Plus
		} else if UIScreen.main.bounds.size.width == 375 {
			return DeviceSize.iPhone8
		} else {
			return DeviceSize.iPhone13
		}
	}
	
	enum DeviceSize {
		case iPhone13
		case iPhone13ProMax
		case iPhoneMini
		case iPhone11ProMax
		case iPhone11
		case iPhone8Plus
		case iPhone8
		case iPhoneSE
		
		// MARK: MyDiariesView
		var TabBarTitleLabelLeading: Int {
			switch self {
			default: return 20
			}
		}
		
		var TabBarTitleLabelTop: Int {
			switch self {
			default: return 30
			}
		}
		
		var TabBarTitleFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 28) ?? UIFont.systemFont(ofSize: 28)
			}
		}
		
		var MyDiariesViewAddDiaryButtonSize: CGFloat {
			switch self {
			default: return 50
			}
		}
		
		var MyDiariesViewAddDiaryButtonPadding: Int {
			switch self {
			default: return 20
			}
		}
		
		// MARK: MyDiariesViewCustomModalView
		var MyDiariesViewCustomModalViewButtonHeight: Int {
			switch self {
			default: return 50
			}
		}
		
		var MyDiariesViewCustomModalViewStackWidth: Int {
			switch self {
			default: return 150
			}
		}
		
		var MyDiariesViewCustomModalViewStackTrailing: Int {
			switch self {
			default: return 20
			}
		}
		
		var MyDiariesViewCustomModalViewStackBottom: Int {
			switch self {
			default: return 140
			}
		}
		
		// MARK: DiaryCollectionView
		var diaryContributerImageViewSize: Int {
			switch self {
			default: return 25
			}
		}
		
		var diaryContributerImageViewTrailing: Int {
			switch self {
			default: return 13
			}
		}
		
		var diaryContributerImageViewBottom: Int {
			switch self {
			default: return 10
			}
		}

		var diaryCollectionViewCellSize: CGSize {
			switch self {
			default: return CGSize(width: 165, height: 207)
			}
		}
		
		var diaryCollectionViewCellHeaderWidthPadding: CGFloat {
			switch self {
			default: return 40
			}
		}
		
		var diaryCollectionViewCellHeaderHeight: CGFloat {
			switch self {
			default: return 30
			}
		}
		
		var diaryCollectionViewCellHeaderTop: CGFloat {
			switch self {
			default: return 30
			}
		}
		
		var diaryCollectionViewCellTop: CGFloat {
			switch self {
			default: return 30
			}
		}
		
		var diaryCollectionViewCellLeading: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTrailing: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellBottom: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelLeading: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelTrailing: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelTop: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 24) ?? UIFont.systemFont(ofSize: 24)
			}
		}
		
		// MARK: MyPlaceView
		var mapViewTop: Int {
			switch self {
			default: return 145
			}
		}
		
		var mapViewBottom: Int {
			switch self {
			default: return 30
			}
		}
		
		var annotationSize: CGSize {
			switch self {
			default: return CGSize(width: 52, height: 60)
			}
		}
		
		var annotationTitleFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 10) ?? UIFont.systemFont(ofSize: 10)
			}
		}
		
		var clusterAnnotationLabelFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 13) ?? UIFont.systemFont(ofSize: 13)
			}
		}
		
		var clusterAnnotationSize: CGSize {
			switch self {
			default: return CGSize(width: annotationSize.width+12, height: annotationSize.height+12)
			}
		}
		
		var clusterAnnotationImageFrame: CGRect {
			switch self {
			default: return CGRect(x: 0, y: 12, width: annotationSize.width, height: annotationSize.height)
			}
		}
		
		var clusterAnnotationLabelFrame: CGRect {
			switch self {
			default: return CGRect(x: annotationSize.width-15, y: 0, width: 25, height: 25)
			}
		}
		
		// MARK: Album
		var myAlbumPhotoPageLabelFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
			}
		}
		
		// All
		var collectionBackgoundViewFont: UIFont {
			switch self {
			default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
			}
		}
        

// MARK: - Sign In
        var logInButtonSize: CGSize {
            switch self {
            default: return CGSize(width: 268, height: 50)
            }
        }
        
        var logInButtonBottomInset: CGFloat {
            switch self {
            default: return 80
            }
        }
        
        var logInButtonImagePointSize: CGFloat {
            switch self {
            default: return 17
            }
        }
        
        var loginButtonFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
        
        // MARK: Page
        var pagePadding: CGFloat {
            switch self {
            default: return CGFloat(10)
            }
        }
        
        var pageToolButtonInterval: CGFloat {
            switch self {
            default: return CGFloat(10)
            }
        }

        var pageDescriptionLabelFont: UIFont {
            switch self {
            default: return UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }
        
        var pageToolButtonSize: CGSize {
            switch self {
            default: return CGSize(width: 30, height: 30)
            }
        }
        
        var pageToolButtonPointSize: CGFloat {
            switch self {
            default: return CGFloat(18)
            }
        }
        
        // MARK: PageToolViewController
        var mapSearchViewSearchBarTopPadding: CGFloat {
            switch self {
            default: return CGFloat(20)
            }
        }
        
        var stickerPickerPadding: CGFloat {
            switch self {
            default: return CGFloat(10)
            }
        }
        
        var stickerPickerButtonFrameSize: CGSize {
            switch self {
            default: return CGSize(width: 35, height: 35)
            }
        }
        
        var stickerPickerButtonPointSize: CGFloat {
            switch self {
            default: return CGFloat(18)
            }
        }
        
        // MARK: Sticker
        var stickerDefaultSize: CGSize {
            switch self {
            default: return CGSize(width: 100, height: 100)
            }
        }
        
        var stickerControllerSize: CGSize {
            switch self {
            default: return CGSize(width: 22, height: 22)
            }
        }
        
        var stickerBorderWidth: CGFloat {
            switch self {
            default: return CGFloat(1)
            }
        }
        
        var stickerBorderInset: CGFloat {
            switch self {
            default: return CGFloat(5)

            }
        }
        
// MARK: - Diary Config
        var diaryConfigTitleFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.boldSystemFont(ofSize: 17)
            }
        }
        
        var diaryConfigButtonFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
        
        var diaryConfigTitleTopInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
        var diaryConfigCancelButtonLeftInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
        var diaryConfigDoneButtonRightInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
        var diaryConfigCollectionViewInset: CGFloat {
            switch self {
            default: return 40
            }
        }
        
        var diaryConfigCollectionViewCellHeight: CGFloat {
            switch self {
            default: return 86
            }
        }
        
        var diaryConfigCollectionViewCellInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
// MARK: - Diary Config Cell
        var diaryConfigCellTitleFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
        
        var diaryConfigCellContentFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
        
        var diaryConfigCellTopInset: CGFloat {
            switch self {
            default: return 10
            }
        }
        
        var diaryConfigCellLeftInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
        var diaryConfigCellBottomInset: CGFloat {
            switch self {
            default: return 10
            }
        }
        
        var diaryConfigCellRightInset: CGFloat {
            switch self {
            default: return 20
            }
        }
        
// MARK: - My Diary Pages
// MARK: - PopUp Modal View
        var popUpModalFont: UIFont {
            switch self {
            default: return UIFont(name: "EF_Diary", size: 17) ?? UIFont.systemFont(ofSize: 17)
            }
        }
	}

}
