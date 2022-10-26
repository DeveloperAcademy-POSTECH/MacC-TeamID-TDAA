//
//  CustomAnnotationView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import MapKit

class CustomAnnotationView: MKAnnotationView {
	static let identifier = "CustomAnnotationView"
	
	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		frame = CGRect(x: 0, y: 0, width: 40, height: 90)
		centerOffset = CGPoint(x: 0, y: -frame.size.height / 2)
		setupUI()
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func setupUI() {
		backgroundColor = .clear
	}
	
}


class CustomAnnotation: NSObject, MKAnnotation {
	let title: String?
	let coordinate: CLLocationCoordinate2D
	let diaryTitle: String
	
	init(coordinate: CLLocationCoordinate2D, diaryTitle: String, title: String) {
		self.coordinate = coordinate
		self.diaryTitle = diaryTitle
		self.title = title
		
		super.init()
	}
	
}
