//
//  Notification+.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/27.
//
import Foundation

extension Notification.Name {
	static let reloadDiary = Notification.Name("reloadDiary")
	static let changeAddButtonImage = Notification.Name("changeAddButtonImage")
	static let mapAnnotationTapped = Notification.Name("mapAnnotationTapped")
	static let paging = Notification.Name("paging")
	static let mapListSwipeLeft = Notification.Name("mapListSwipeLeft")
	static let mapListSwipeRight = Notification.Name("mapListSwipeRight")
	static let mapListTapped = Notification.Name("mapListTapped")
    static let isNavigationConfirmButtonEnabled = NSNotification.Name("isNavigationConfirmButtonEnabled")
}
