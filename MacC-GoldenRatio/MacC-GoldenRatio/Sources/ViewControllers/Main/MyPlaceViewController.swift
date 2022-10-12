//
//  MyPlacesViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/09/29.
//

import CoreLocation
import MapKit
import UIKit

class MyPlaceViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

	let mapView = MapView()
	
	let locations = [CLLocationCoordinate2D(latitude: 37.51818789942702, longitude: 126.88541765534906)]
	
	let locationManager = CLLocationManager()
	
	override func loadView() {
		view = mapView
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view.
		locationManager.requestWhenInUseAuthorization()
		
//		mapView.map.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 127.0016985, longitude: 37.5642135), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
		mapView.map.delegate = self
		
		locationManager.delegate = self
		
		addCustomPin(locations: locations)
	}

	private func addCustomPin(locations: [CLLocationCoordinate2D]) {
		for location in locations {
			let pin = MKPointAnnotation()
			pin.coordinate = location
			pin.title = "3"
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

