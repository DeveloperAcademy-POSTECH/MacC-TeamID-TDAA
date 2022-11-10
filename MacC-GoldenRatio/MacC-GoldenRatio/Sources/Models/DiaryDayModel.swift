//
//  DiaryDayModel.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import UIKit

struct DiaryDayModel {
    let dayLabel: String
    let dateLabel: String
    let image: UIImage?

    init(dayLabel: String, dateLabel: String, image: UIImage?) {
        self.dayLabel = dayLabel
        self.dateLabel = dateLabel
        self.image = image
    }
}
