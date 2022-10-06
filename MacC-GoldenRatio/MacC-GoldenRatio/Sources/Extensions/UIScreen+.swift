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
		
		var MyDiariesViewTitleLabelLeadingPadding: Int {
			switch self {
			default: return 20
			}
		}
		
		var MyDiariesViewTitleLabelTopPadding: Int {
			switch self {
			default: return 20
			}
		}
		
		var MyDiariesViewTitleFontSize: CGFloat {
			switch self {
			default: return 28
			}
		}
		
		var MyDiariesViewCreateDiaryButtonSize: CGFloat {
			switch self {
			default: return 50
			}
		}
		
		var MyDiariesViewCreateDiaryButtonPadding: Int {
			switch self {
			default: return 20
			}
		}
		
		var diaryContributerImageViewSize: Int {
			switch self {
			default: return 25
			}
		}
		
		var diaryContributerImageViewTrailingPadding: Int {
			switch self {
			default: return 13
			}
		}
		
		var diaryContributerImageViewBottomPadding: Int {
			switch self {
			default: return 10
			}
		}

		var diaryCollectionViewCellWidth: Int {
			switch self {
			default: return 165
			}
		}
		
		var diaryCollectionViewCellHeight: Int {
			switch self {
			default: return 207
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
		
		var diaryCollectionViewCellHeaderHeightPadding: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTopInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellLeadingInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTrailingInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellBottomInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelLeadingInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelTrailingInset: CGFloat {
			switch self {
			default: return 20
			}
		}
		
		var diaryCollectionViewCellTitleLabelTopInset: CGFloat {
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
        
// MARK: - Diary Config
        var diaryConfigTitleFont: UIFont {
            switch self {
            default: return UIFont.boldSystemFont(ofSize: 17)
            }
        }
        
        var diaryConfigButtonFont: UIFont {
            switch self {
            default: return UIFont.systemFont(ofSize: 17)
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
            default: return UIFont.boldSystemFont(ofSize: 22)
            }
        }
        
        var diaryConfigCellContentFont: UIFont {
            switch self {
            default: return UIFont.systemFont(ofSize: 17)
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
        
	}

}
