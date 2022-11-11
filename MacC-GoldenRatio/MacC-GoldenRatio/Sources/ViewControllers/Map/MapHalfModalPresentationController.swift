//
//  HalfModalPresentationViewController.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/10.
//
import UIKit

class MapHalfModalPresentationController: UIPresentationController {
	let blurEffectView: UIVisualEffectView!
	var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
	
	override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
		let blurEffect = UIBlurEffect(style: .dark)
		blurEffectView = UIVisualEffectView(effect: blurEffect)
		super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
		tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
		blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		self.blurEffectView.isUserInteractionEnabled = true
		self.blurEffectView.addGestureRecognizer(tapGestureRecognizer)
	}
	
	override var frameOfPresentedViewInContainerView: CGRect {
		CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height * 0.45),
			   size: CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height *
							0.55))
	}
	
	override func presentationTransitionWillBegin() {
		self.blurEffectView.alpha = 0
		self.containerView?.addSubview(blurEffectView)
		self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
			self.blurEffectView.alpha = 0.2
		}, completion: { (UIViewControllerTransitionCoordinatorContext) in })
	}
	
	override func dismissalTransitionWillBegin() {
		self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: { (UIViewControllerTransitionCoordinatorContext) in
			self.blurEffectView.alpha = 0
		}, completion: { (UIViewControllerTransitionCoordinatorContext) in
			self.blurEffectView.removeFromSuperview()
		})
	}
	
	override func containerViewWillLayoutSubviews() {
		super.containerViewWillLayoutSubviews()
		presentedView?.layer.cornerRadius = 22
		presentedView?.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
		presentedView?.layer.masksToBounds = true
	}
	
	override func containerViewDidLayoutSubviews() {
		super.containerViewDidLayoutSubviews()
		presentedView?.frame = frameOfPresentedViewInContainerView
		blurEffectView.frame = containerView!.bounds
	}
	
	@objc func dismissController(){
		self.presentedViewController.dismiss(animated: true, completion: nil)
	}
}

extension MapHalfModalPresentationController: UIViewControllerTransitioningDelegate {
	
	func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
		MapHalfModalPresentationController(presentedViewController: presented, presenting: presenting)
	}
}
