//
//  HalfModalPresentationController.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/04.
//

import UIKit

class HalfModalPresentationController: UIPresentationController {
    let backgroundView: UIView = UIView()
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    
    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentedViewController)
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissController))
        backgroundView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override var frameOfPresentedViewInContainerView: CGRect {
        let viewSize = CGSize(width: self.containerView!.frame.width, height: self.containerView!.frame.height * 2 / 5)
        return CGRect(origin: CGPoint(x: 0, y: self.containerView!.frame.height * 3 / 5), size: viewSize)
    }
    
    // 모달 올라갈 때
    override func presentationTransitionWillBegin() {
        self.containerView?.addSubview(backgroundView)
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: nil, completion: nil)
    }
    
    // 모달 없어질 때
    override func dismissalTransitionWillBegin() {
        self.presentedViewController.transitionCoordinator?.animate(alongsideTransition: nil){ _ in
            self.backgroundView.removeFromSuperview()
        }
    }
    
    // 모달 크기가 조절됐을 때
    override func containerViewDidLayoutSubviews() {
        super.containerViewDidLayoutSubviews()
        self.presentedView?.layer.cornerRadius = 15
        self.backgroundView.frame = self.containerView!.frame
    }
    
    @objc func dismissController() {
        self.presentedViewController.dismiss(animated: true, completion: nil)
    }
}
