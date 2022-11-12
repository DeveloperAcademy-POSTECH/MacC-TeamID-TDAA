//
//  UIImage+.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/03.
//

import UIKit

extension UIView {
    func transformToImage() -> UIImage? {
        /*
        테스트 중인 코드입니다.
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0.0)
        */
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        return renderer.image { rendererContext in
            layer.render(in: rendererContext.cgContext)
        }
    }
    func convertViewToImageView() -> UIImageView {
        let image = self.transformToImage()
        let imageView = UIImageView(image: image)
        imageView.frame = self.frame
        return imageView
    }
    
    func convertViewToImageView(completion: @escaping (UIView) -> Void) {
        DispatchQueue.main.async {
            let renderer = UIGraphicsImageRenderer(bounds: self.bounds)
            let image = renderer.image { rendererContext in
                self.layer.render(in: rendererContext.cgContext)
            }
            
            let imageView = UIImageView(image: image)
            imageView.frame = self.frame
            
            completion(imageView)
        }
    }
	
	func showToastMessage(_ message: String, font: UIFont = UIFont(name: "EF_Diary", size: 12) ?? UIFont.systemFont(ofSize: 12)) {
		let toastLabel = UILabel(frame: CGRect(x: self.bounds.midX-90, y: self.frame.height - 150, width: 180, height: 30))
		
		toastLabel.backgroundColor = UIColor.black.withAlphaComponent(0.5)
		toastLabel.textColor = UIColor.white
		toastLabel.numberOfLines = 2
		toastLabel.font = font
		toastLabel.text = message
		toastLabel.textAlignment = .center
		toastLabel.layer.cornerRadius = 15
		toastLabel.clipsToBounds = true
		
		self.addSubview(toastLabel)

		UIView.animate(withDuration: 1.5, delay: 1.0, options: .curveEaseOut) {
			toastLabel.alpha = 0.0
		} completion: { _ in
			toastLabel.removeFromSuperview()
		}
	}
	
    func setUnderLine(width: CGFloat) {
        let view = UIView()
        view.backgroundColor = .buttonColor
        self.addSubview(view)
        view.snp.makeConstraints { make in
            make.bottom.horizontalEdges.equalToSuperview()
            make.height.equalTo(width)
        }
    }
}
