//
//  MyPlacesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import RxCocoa
import RxSwift
import MapKit
import SnapKit
import UIKit

class MyPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	private let disposeBag = DisposeBag()
	private let myDevice = UIScreen.getDevice()
	private let mapView = MapView()
	
	override func loadView() {
		super.loadView()
		view = mapView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
	}
	
	func bind(_ viewModel: MapViewModel) {
		mapView.bind(viewModel)
	}
}
