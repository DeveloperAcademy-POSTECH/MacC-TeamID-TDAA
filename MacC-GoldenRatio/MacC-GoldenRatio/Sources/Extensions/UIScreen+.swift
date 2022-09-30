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
		
		var titleLabelLeadingPadding: Int {
			switch self {
			default: return 20
			}
		}
		
		var titleLabelTopPadding: Int {
			switch self {
			default: return 45
			}
		}
		
		var titleFontSize: CGFloat {
			switch self {
			default: return 28
			}
		}
		
		var diaryContributerImageViewTrailingPadding: Int {
			switch self {
			default: return 24
			}
		}
		
		var diaryContributerImageViewBottomPadding: Int {
			switch self {
			default: return 24
			}
		}

		var diaryCollectionViewCellWidth: Int {
			switch self {
			default: return 350
			}
		}
		
		var diaryCollectionViewCellHeight: Int {
			switch self {
			default: return 166
			}
		}
		
		var diaryCollectionViewCellHeaderWidth: CGFloat {
			switch self {
			default: return 32
			}
		}
		
		var diaryCollectionViewCellHeaderHeight: CGFloat {
			switch self {
			default: return 100
			}
		}
		
		var diaryCollectionViewCellTopInset: CGFloat {
			switch self {
			default: return 30
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
			default: return 10
			}
		}
	}

}
