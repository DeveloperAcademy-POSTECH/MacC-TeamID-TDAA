//
//  LoadingIndicator.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/14.
//

import UIKit

class LoadingIndicator {
	static func showLoading(loadingText: String) {
		DispatchQueue.main.async {
			guard let window = UIApplication.shared.windows.last else { return }
			
			let strLabel = UILabel(frame: CGRect(x: window.frame.midX - 200, y: window.frame.midY, width: 400, height: 66))
			strLabel.text = loadingText
			strLabel.textAlignment = .center
			strLabel.font = .systemFont(ofSize: 18)
			strLabel.textColor = .gray
			
			let loadingIndicatorView: UIActivityIndicatorView
			if let existedView = window.subviews.first(where: { $0 is UIActivityIndicatorView } ) as? UIActivityIndicatorView {
				loadingIndicatorView = existedView
				window.addSubview(strLabel)
			} else {
				loadingIndicatorView = UIActivityIndicatorView(style: .large)
				loadingIndicatorView.frame = window.frame
				loadingIndicatorView.color = .gray
				loadingIndicatorView.frame = CGRect(x: window.frame.midX - 150, y: window.frame.midY - strLabel.frame.height / 2 , width: 300, height: 66)
				
				window.addSubview(loadingIndicatorView)
				window.addSubview(strLabel)
			}
			
			loadingIndicatorView.startAnimating()
		}
	}

	static func hideLoading() {
		DispatchQueue.main.async {
			guard let window = UIApplication.shared.windows.last else { return }
			window.subviews.filter({ $0 is UIActivityIndicatorView }).forEach { $0.removeFromSuperview() }
			window.subviews.filter({ $0 is UILabel }).forEach { $0.removeFromSuperview() }
		}
	}
}
