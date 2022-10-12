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
import UIKit

class MyPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {
	private var cancelBag = Set<AnyCancellable>()
	private let viewModel = MyPlaceViewModel(userUid: Auth.auth().currentUser?.uid ?? "")
	private let mapView = MapView()
	
	let locationManager = CLLocationManager()
	
	override func loadView() {
		view = mapView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		locationManager.requestWhenInUseAuthorization()
		
		mapView.map.delegate = self
		
		locationManager.delegate = self
		
	}

	private func addCustomPin(_ mapData: [MapData]) {
		mapData.forEach { data in
			let pin = MKPointAnnotation()
			pin.coordinate = CLLocationCoordinate2D(latitude: data.location.locationCoordinate[1], longitude: data.location.locationCoordinate[0])
			
			mapView.map.addAnnotation(pin)
		}
	}
	
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		guard !annotation.isKind(of: MKUserLocation.self) else {
			return nil
		}
		
		var annotationView = self.mapView.map.dequeueReusableAnnotationView(withIdentifier: "Custom")

		if annotationView == nil {
			annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "Custom")
			annotationView?.canShowCallout = true

			let miniButton = UIButton(frame: CGRect(x: 0, y: 0, width: 20, height: 20))
			miniButton.setImage(UIImage(systemName: "person"), for: .normal)
			miniButton.tintColor = .blue
			annotationView?.rightCalloutAccessoryView = miniButton
		} else {
			annotationView?.annotation = annotation
		}
		
		annotationView?.image = UIImage(systemName: "circle.fill")
		
		let annotationLabel = UILabel(frame: CGRect(x: 0, y: -35, width: 45, height: 15))
		annotationLabel.backgroundColor = .systemOrange
		annotationLabel.textColor = .white
		annotationLabel.numberOfLines = 3
		annotationLabel.textAlignment = .center
		annotationLabel.font = UIFont.boldSystemFont(ofSize: 10)
		annotationLabel.text = annotation.title!
		
		annotationView?.addSubview(annotationLabel)
		
		return annotationView
	}

}

private extension MyPlaceViewController {
	func setupViewModel() {
		viewModel.$mapDatas
			.receive(on: DispatchQueue.main)
			.sink { [weak self] data in
				self?.addCustomPin(data)
			}
			.store(in: &cancelBag)
	}
}
