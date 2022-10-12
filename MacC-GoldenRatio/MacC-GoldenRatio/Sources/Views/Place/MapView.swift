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
	private let myDevice = UIScreen.getDevice()
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
		map.snp.makeConstraints {
			$0.top.equalToSuperview().inset(myDevice.mapViewTop)
			$0.bottom.equalTo(self.safeAreaLayoutGuide).inset(myDevice.mapViewBottom)
			$0.leading.trailing.equalToSuperview()
		}
	}
}
