//
//  CustomAnnotationClusterView.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/13.
//

import MapKit

class CustomClusterAnnotationView: MKAnnotationView {
	static let clusterID = "diary"
	private let myDevice = UIScreen.getDevice()

	override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
		super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
		collisionMode = .circle
		centerOffset = CGPoint(x: 0, y: -10)
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func prepareForDisplay() {
		super.prepareForDisplay()
		if let cluster = annotation as? MKClusterAnnotation {
			let totalDiary = cluster.memberAnnotations.count
			if totalDiary > 0 {
				let stampName = UIImage(named: "diaryBlue") ?? UIImage()
				let size = UIScreen.getDevice().AnnotationSize
				UIGraphicsBeginImageContext(size)

				stampName.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
				let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
				
				image = createImageWithLabelOverlay(text: "\(totalDiary)", imageSize: UIScreen.getDevice().AnnotationSize, image: resizedImage ?? UIImage()) ?? UIImage()
				displayPriority = .defaultLow
			}
		}
	}
	
	func createImageWithLabelOverlay(text: String, imageSize: CGSize, image: UIImage) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(myDevice.ClusterAnnotationSize, false, 2.0)
		let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: myDevice.ClusterAnnotationSize.width, height: myDevice.ClusterAnnotationSize.height))
		
		let currentImage = UIImageView.init(image: image)
		currentImage.frame = myDevice.ClusterAnnotationImageFrame
		currentImage.layer.borderWidth = 1
		currentImage.layer.borderColor = UIColor.white.cgColor
		currentView.addSubview(currentImage)
		
		let label = UILabel(frame: myDevice.ClusterAnnotationLabelFrame)
		label.font = myDevice.ClusterAnnotationLabelFont
		label.clipsToBounds = true
		label.layer.cornerRadius = 12
		label.backgroundColor = UIColor.black
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.text = text
		
		currentView.addSubview(label)
		currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img
	}

}
