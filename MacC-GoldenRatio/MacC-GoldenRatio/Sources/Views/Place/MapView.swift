//
//  MapView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/12.
//

import MapKit
import SnapKit
import UIKit

class MapView: UIView{
	let map = MKMapView()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		
		self.addSubview(map)
		makeConstraints()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func makeConstraints() {
		map.snp.makeConstraints { make in
			make.top.leading.trailing.bottom.equalToSuperview()
		}
	}
}
