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
				let stampName = UIImage(named: "stampLayout") ?? UIImage()
				let size = UIScreen.getDevice().annotationSize
				UIGraphicsBeginImageContext(size)

				stampName.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height-70))
				let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
				if let title = cluster.memberAnnotations[0].title {
					image = createImageWithLabelOverlay(title: "\(title!)", count: "\(totalDiary)", imageSize: UIScreen.getDevice().annotationSize, image: resizedImage ?? UIImage()) ?? UIImage()
				} else {
					image = createImageWithLabelOverlay(title: "", count: "\(totalDiary)", imageSize: UIScreen.getDevice().annotationSize, image: resizedImage ?? UIImage()) ?? UIImage()
				}
				displayPriority = .defaultLow
			}
		}
	}
	
	func createImageWithLabelOverlay(title: String, count: String, imageSize: CGSize, image: UIImage) -> UIImage? {
		UIGraphicsBeginImageContextWithOptions(myDevice.clusterAnnotationSize, false, 2.0)
		let currentView = UIView.init(frame: CGRect(x: 0, y: 0, width: myDevice.clusterAnnotationSize.width, height: myDevice.clusterAnnotationSize.height))
		
		let currentImage = UIImageView.init(image: image)
		currentImage.frame = myDevice.clusterAnnotationImageFrame
		currentView.addSubview(currentImage)
		
		lazy var countLabel: UILabel = {
			let label = UILabel(frame: myDevice.clusterAnnotationCountLabelFrame)
			label.font = myDevice.clusterAnnotationLabelFont
			label.clipsToBounds = true
			label.layer.cornerRadius = 12
			label.backgroundColor = UIColor(named: "sandbrownColor") ?? UIColor.black
			label.textColor = UIColor.white
			label.textAlignment = .center
			label.text = count
			return label
		}()
		
		lazy var titleLabel: UILabel = {
			let label = UILabel(frame: myDevice.clusterAnnotationTitleLabelFrame)
			label.font = myDevice.annotationTitleFont
			label.textColor = UIColor.darkgrayColor
			label.textAlignment = .center
			label.text = title
			return label
		}()
		
		[titleLabel, countLabel].forEach { currentView.addSubview($0) }
		
		currentView.layer.render(in: UIGraphicsGetCurrentContext()!)
		let img = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		return img
	}

}
