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
	private let mapModel = MapModel()
	private let locationManager = CLLocationManager()
	private var selectedLocation: Location?
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
		layout()
	}
	
	required init?(coder: NSCoder) {
		fatalError()
	}
	
	func setup() {
		map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		map.delegate = self
		locationManager.requestWhenInUseAuthorization()
		locationManager.delegate = self
		NotificationCenter.default.addObserver(self, selector: #selector(mapListTapped(notification:)), name: .mapListTapped, object: nil)
	}
	
	func bind(_ viewModel: MapViewModel) {
		let allAnnotations = self.map.annotations
		self.map.removeAnnotations(allAnnotations)
		
		let locations = viewModel.mapData
			.value.first?.diaryLocation
		
		viewModel.mapAnnotations
			.asObservable()
			.subscribe(onNext: { data in
				data.forEach { annotations in
					self.map.addAnnotations(annotations)
				}
			})
			.disposed(by: disposeBag)
		
		viewModel.mapCellData
			.asObservable()
			.map {
				return self.selectedLocation != nil ? self.mapModel.changeIndex($0, selectedLocation: self.selectedLocation!) : $0
			}
			.subscribe(onNext: { data in
				let location = data.first?.locationCoordinate ?? [locations?.locationCoordinate[0] ?? 37.56667, locations?.locationCoordinate[1] ?? 126.97806]
				let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: location[0], longitude: location[1]), span: self.map.region.span)
				self.map.setRegion(self.map.regionThatFits(region), animated: true)
			})
			.disposed(by: disposeBag)
		
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: locations?.locationCoordinate[0] ?? 37.56667, longitude: locations?.locationCoordinate[1] ?? 126.97806), latitudinalMeters: CLLocationDistance(exactly: 15000) ?? 0, longitudinalMeters: CLLocationDistance(exactly: 15000) ?? 0)
		self.map.setRegion(self.map.regionThatFits(region), animated: true)
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
		annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: CustomAnnotationView.identifier)
		annotationView?.canShowCallout = false
		annotationView?.contentMode = .scaleAspectFit
		
		let countLabel = UILabel()
		countLabel.text = "\(annotation.day)"
		countLabel.font = .boldSubheadline
		countLabel.textColor = UIColor.darkgrayColor
		countLabel.textAlignment = .center
		
		annotationView?.addSubview(countLabel)
		
		countLabel.snp.makeConstraints {
			$0.height.equalTo(22)
			$0.top.equalToSuperview().inset(5)
			$0.leading.equalToSuperview().inset(11)
		}
		
		annotationView?.image = UIImage(named: "\(annotation.iconImage)") ?? UIImage()
		
		return annotationView
	}
	
	func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
		guard let view = view.annotation as? CustomAnnotation else {
			return
		}
		
		selectedLocation = Location(locationName: view.title ?? "", locationAddress: view.address, locationCoordinate: [view.coordinate.latitude, view.coordinate.longitude], locationCategory: view.category)
		
		NotificationCenter.default.post(name: .mapAnnotationTapped, object: nil, userInfo: ["day": view.day, "selectedLocation": Location(locationName: view.title ?? "", locationAddress: view.address, locationCoordinate: [view.coordinate.latitude, view.coordinate.longitude], locationCategory: view.category)])
		
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: view.coordinate.latitude, longitude: view.coordinate.longitude), span: self.map.region.span)
		self.map.setRegion(self.map.regionThatFits(region), animated: true)
	}
	
	@objc private func mapListTapped(notification: NSNotification) {
		guard let selectedLocation = notification.userInfo?["location"] as? Location else {
			return
		}
		
		let region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: selectedLocation.locationCoordinate[0], longitude: selectedLocation.locationCoordinate[1]), span: self.map.region.span)
		
		self.map.setRegion(self.map.regionThatFits(region), animated: true)
	}
}
