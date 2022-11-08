//
//  DiarySection.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/06.
//

import Foundation
import RxDataSources

struct DiarySection {
	var header: String
	var items: [Diary]
}

extension DiarySection: SectionModelType {
	typealias Item = Diary
	
	init(original: DiarySection, items: [Diary]) {
		self = original
		self.items = items
	}
}
