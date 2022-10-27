//
//  MyPlacesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import Combine
import CoreLocation
import FirebaseAuth
import MapKit
import SnapKit
import UIKit

class MyPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	private var cancelBag = Set<AnyCancellable>()
	private let viewModel = MyPlaceViewModel()
	private let myDevice = UIScreen.getDevice()
	private let mapView = MapView()
	private let locationManager = CLLocationManager()
	
	private lazy var titleLabel: UILabel = {
		let label = UILabel()
		label.text = "지도"
		label.font = myDevice.TabBarTitleFont
		label.textColor = UIColor.buttonColor
		
		return label
	}()
	
	override func loadView() {
		view = mapView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		setup()
		setupSubView()
		setupRegister()
		setupViewModel()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		setupViewModel()
	}
	
	private func setup() {
		locationManager.requestWhenInUseAuthorization()
		locationManager.delegate = self
		mapView.map.delegate = self
		self.view.backgroundColor = UIColor(patternImage: UIImage(named: "backgroundTexture.png") ?? UIImage())
	}
	
	private func setupSubView() {
		view.addSubview(titleLabel)
		titleLabel.snp.makeConstraints {
			$0.top.equalTo(view.safeAreaLayoutGuide).inset(myDevice.TabBarTitleLabelTop)
			$0.leading.equalToSuperview().inset(myDevice.TabBarTitleLabelLeading)
		}
		mapView.map.snp.makeConstraints {
			$0.top.equalTo(titleLabel.snp.bottom).offset(myDevice.mapViewTop)
			$0.bottom.equalTo(self.view.safeAreaLayoutGuide).inset(myDevice.mapViewBottom)
			$0.leading.trailing.equalToSuperview()
		}
	}
	
	private func setupRegister() {
		mapView.map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		mapView.map.register(CustomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
	}

	private func addCustomPin(_ mapData: [MapData]) {
		let allAnnotations = self.mapView.map.annotations
		self.mapView.map.removeAnnotations(allAnnotations)
		mapData.forEach { data in
			let pin = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: data.location.locationCoordinate[0], longitude: data.location.locationCoordinate[1]), diaryTitle: data.diaryName, title: data.diaryName)
			mapView.map.addAnnotation(pin)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? CustomAnnotation else {
			return nil
		}
		
		var annotationView = self.mapView.map.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
		
		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
			annotationView?.canShowCallout = false
			annotationView?.contentMode = .scaleAspectFit
		} else {
			annotationView?.annotation = annotation
		}
		
		if let viewWithTag = annotationView?.viewWithTag(1) {
			viewWithTag.removeFromSuperview()
		}
		
		let diaryTitle = UILabel()
		diaryTitle.tag = 1
		diaryTitle.text = annotation.diaryTitle
		diaryTitle.font = myDevice.annotationTitleFont
		diaryTitle.textColor = UIColor.darkgrayColor
		diaryTitle.textAlignment = .center
		
		annotationView?.addSubview(diaryTitle)
		
		diaryTitle.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalToSuperview().inset(35)
		}
		
		let stampName = UIImage(named: "stampLayout") ?? UIImage()
		let size = myDevice.annotationSize
		UIGraphicsBeginImageContext(size)
		
		stampName.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height-70))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		annotationView?.image = resizedImage
		
		annotationView?.clusteringIdentifier = "diary"
		
		return annotationView
	}

}

private extension MyPlaceViewController {
	func setupViewModel() {
		viewModel.fetchLoadData()
		viewModel.$mapDatas
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				self?.addCustomPin(data)
			}
			.store(in: &cancelBag)
	}
}
