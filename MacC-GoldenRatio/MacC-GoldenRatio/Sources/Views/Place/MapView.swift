//
//  MapView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/12.
//

import RxSwift
import MapKit
import SnapKit
import UIKit

class MapView: UIView, MKMapViewDelegate, CLLocationManagerDelegate {
	private let disposeBag = DisposeBag()
	private let map = MKMapView()
	private let myDevice = UIScreen.getDevice()
	private let locationManager = CLLocationManager()
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		map.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.delegate = self
		layout()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func bind(_ viewModel: MapViewModel) {
		let allAnnotations = self.map.annotations
		self.map.removeAnnotations(allAnnotations)
		viewModel.mapData
			.value
			.forEach { data in
				let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: data.diaryLocation.locationCoordinate[0], longitude: data.diaryLocation.locationCoordinate[1]), latitudinalMeters: CLLocationDistance(exactly: 15000) ?? 0, longitudinalMeters: CLLocationDistance(exactly: 15000) ?? 0)
				self.map.setRegion(self.map.regionThatFits(region), animated: true)
				data.locations.forEach { location in
					if data.day != 10 {
						let pin = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.locationCoordinate[0], longitude: location.locationCoordinate[1]), title: location.locationName, address: location.locationAddress, day: data.day, iconImage: "pin\(data.day%10)", category: location.locationCategory ?? "")
						map.addAnnotation(pin)
					} else {
						let pin = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: location.locationCoordinate[0], longitude: location.locationCoordinate[1]), title: location.locationName, address: location.locationAddress, day: data.day, iconImage: "pin10", category: location.locationCategory ?? "")
						map.addAnnotation(pin)
					}
				}
			}
	}
	
	func layout() {
		self.addSubview(map)
		map.snp.makeConstraints {
			$0.edges.equalToSuperview()
		}
	}

	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard let annotation = annotation as? CustomAnnotation else {
			return nil
		}
		
		var annotationView = self.map.dequeueReusableAnnotationView(withIdentifier: CustomAnnotationView.identifier)
		
		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
			annotationView?.canShowCallout = false
			annotationView?.contentMode = .scaleAspectFit
		} else {
			annotationView?.annotation = annotation
		}
		
		let countLabel = UILabel()
		countLabel.text = "\(annotation.day)"
		countLabel.font = UIFont.mapLabelFont
		countLabel.textColor = UIColor.darkgrayColor
		countLabel.textAlignment = .center
		
		annotationView?.addSubview(countLabel)
		
		countLabel.snp.makeConstraints {
			$0.center.equalToSuperview()
		}
		
		annotationView?.image = UIImage(named: "\(annotation.iconImage)") ?? UIImage()
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let view = view.annotation as? CustomAnnotation else {
			return
		}
		NotificationCenter.default.post(name: .mapAnnotationTapped, object: nil, userInfo: ["day": view.day, "selectedLocation": Location(locationName: view.title ?? "", locationAddress: view.address, locationCoordinate: [view.coordinate.latitude, view.coordinate.longitude], locationCategory: view.category)])
	}
}
