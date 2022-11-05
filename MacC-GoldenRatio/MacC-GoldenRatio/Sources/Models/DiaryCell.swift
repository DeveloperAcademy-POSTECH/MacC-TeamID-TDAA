//
//  DiaryCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/11.
//

import Foundation
import RxDataSources

struct DiarySection {
	var header: String
	var items: [DiaryCell]
}

struct DiaryCell {
	let diaryUUID: String
	let diaryName: String
	let diaryCover: String
}

extension DiarySection: SectionModelType {
	typealias Item = DiaryCell
	
	init(original: DiarySection, items: [DiaryCell]) {
		self = original
		self.items = items
	}
}
