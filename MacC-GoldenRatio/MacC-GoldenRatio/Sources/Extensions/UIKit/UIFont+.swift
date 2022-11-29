//
//  UIFont+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/13.
//

import UIKit

extension UIFont {
    static var navigationTitleFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 17)!
        return font
    }
    /// 20
    static var labelTitleFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 20)!
        return font
    }
    /// 17
    static var labelTtitleFont2: UIFont {
        let font = UIFont(name: "EF_Diary", size: 17)!
        return font
    }
    
    /// 11
    static var labelSubTitleFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 11)!
        return font
    }
    /// 13
    static var labelSubTitleFont2: UIFont {
        let font = UIFont(name: "EF_Diary", size: 13)!
        return font
    }
    /// 28
    static var tabTitleFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 28)!
        return font
    }
    ///12
    static var toastMessageFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 12)!
        return font
    }
    ///24
    static var dayLabelFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 24)!
        return font
    }
	
	static var mapLabelFont: UIFont {
		let font = UIFont(name: "GothicA1-Bold", size: 10) ?? UIFont.systemFont(ofSize: 10)
		return font
	}
	
	static var diaryTitleLabelFont: UIFont {
		let font = UIFont(name: "EF_Diary", size: 20) ?? UIFont.systemFont(ofSize: 20)
		return font
	}
	
	static var diaryDateLabelFont: UIFont {
		let font = UIFont(name: "EF_Diary", size: 10) ?? UIFont.systemFont(ofSize: 10)
		return font
	}
	
	static var diaryAddressLabelFont: UIFont {
		let font = UIFont(name: "EF_Diary", size: 8) ?? UIFont.systemFont(ofSize: 8)
		return font
	}

	static var homeFilterButtonTitleFont: UIFont {
		let font = UIFont(name: "EF_Diary", size: 12) ?? UIFont.systemFont(ofSize: 12)
		return font
	}

    static var previewDayLabelFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 22) ?? UIFont.systemFont(ofSize: 22)
        return font
    }
    
    static var previewDateLabelFont: UIFont {
        let font = UIFont(name: "EF_Diary", size: 18) ?? UIFont.systemFont(ofSize: 18)
        return font
    }
}
