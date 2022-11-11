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
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
}
