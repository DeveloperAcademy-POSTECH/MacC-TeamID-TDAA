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
		var MyDiariesViewTitleLabelLeading: Int {
			switch self {
			default: return 20
			}
		}
		
		var MyDiariesViewTitleLabelTop: Int {
			switch self {
			default: return 20
			}
		}
		
		var MyDiariesViewTitleFont: UIFont {
			switch self {
			default: return UIFont.systemFont(ofSize: 28)
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
			default: return 20
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
            default: return 21.4
            }
        }
        
        var logInButtonFontSize: CGFloat {
            switch self {
            default: return 21.4
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
	}

}
