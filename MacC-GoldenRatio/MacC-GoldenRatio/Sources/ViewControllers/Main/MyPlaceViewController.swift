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
	}
	
	private func setupRegister() {
		mapView.map.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
		mapView.map.register(CustomClusterAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)
	}

	private func addCustomPin(_ mapData: [MapData]) {
		mapData.forEach { data in
			let pin = CustomAnnotation(diaryTitle: data.diaryName, stampName: data.diaryCover, coordinate: CLLocationCoordinate2D(latitude: data.location.locationCoordinate[0], longitude: data.location.locationCoordinate[1]))
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
		
		let diaryTitle = UILabel()
		diaryTitle.text = annotation.diaryTitle
		diaryTitle.font = myDevice.AnnotationTitleFont
		diaryTitle.textAlignment = .center
		
		annotationView?.addSubview(diaryTitle)
		
		diaryTitle.snp.makeConstraints {
			$0.leading.trailing.equalToSuperview()
			$0.top.equalToSuperview().inset(10)
		}
		
		let stampName = UIImage(named: annotation.stampName) ?? UIImage()
		let size = myDevice.AnnotationSize
		UIGraphicsBeginImageContext(size)
		
		stampName.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
		annotationView?.image = resizedImage
		
		annotationView?.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
		annotationView?.layer.cornerRadius = 5
		annotationView?.layer.borderWidth = 1
		annotationView?.layer.borderColor = UIColor.white.cgColor
		
		annotationView?.clusteringIdentifier = "diary"
		
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
