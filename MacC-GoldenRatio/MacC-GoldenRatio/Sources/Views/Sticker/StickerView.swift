//
//  StickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import MapKit
import RxSwift
import RxCocoa
import SnapKit
import UIKit

protocol StickerViewDelegate {
    func removeSticker(sticker: StickerView)
    func bringStickerToFront(sticker: StickerView)
}

class StickerView: UIView {
    var delegate: StickerViewDelegate!
    var disposeBag = DisposeBag()
    
    internal var stickerViewData: StickerViewData?
    internal let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()

    internal var touchStart: CGPoint?
    private var previousPoint: CGPoint?
    private var deltaAngle: CGFloat?

    private var resizingController: StickerControllerView!
    private var deleteController: StickerControllerView!
    private var borderView: StickerBorderView!

    private var oldBounds: CGRect!
    private var oldTransform: CGAffineTransform!

    /// 스티커 뷰의 활성 상태를 나타내는 변수입니다. Local 상에서만 다뤄집니다. 즉, 서버 데이터에 업데이트 되지 않습니다.
    var isStickerViewActive: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    var isStickerViewMode: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        DispatchQueue.main.async {
            self.setupDefaultAttributes()
        }
    }

    func fetchItem() throws -> Item {
        do {
            guard let stickerViewData = self.stickerViewData else { throw ErrorMessage.stickerViewDataDoesntExist }
            let stickerViewItem = try stickerViewData.itemObservable.value()

            return stickerViewItem
        } catch {
            throw error
        }
    }

    func updateIsStickerViewActive(value: Bool) {
        
        if !value {
            enableTranslucency(state: value)
        }
        
        self.isStickerViewActive.onNext(value)
            
    }
    
    internal func configureNewStickerView() {
        self.isStickerViewActive.onNext(true)
    }
    
    internal func stickerUIDidChange() async {
        Task {
            await self.stickerViewData?.updateUIItem(frame: self.frame, bounds: self.bounds, transform: self.transform)
        }
    }
    
    /// StickerViewData 를 현재 View의 프로퍼티들와 binding 합니다.
    internal func configureStickerViewData() async {
        
        self.stickerViewData?.frameObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.frame = $0
            })
            .disposed(by: self.disposeBag)
        
        self.stickerViewData?.boundsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.bounds = $0
            })
            .disposed(by: self.disposeBag)
        
        self.stickerViewData?.transitionObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                self.transform = $0
            })
            .disposed(by: self.disposeBag)

    }
    
    internal func setupContentView(content: UIView) {
        DispatchQueue.main.async {
            let contentView = UIView(frame: content.frame)
            contentView.backgroundColor = .clear
            contentView.addSubview(content)
            self.addSubview(contentView)
            contentView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            content.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    internal func updateControlsPosition() {
        DispatchQueue.main.async {
            let inset = self.myDevice.stickerBorderInset
            self.borderView.frame = CGRect(x: -inset, y: -inset, width: self.bounds.size.width + inset * 2,
                                           height: self.bounds.size.height + inset * 2)
            self.deleteController.center = CGPoint(x: self.borderView.frame.maxX, y: self.borderView.frame.origin.y)
            self.resizingController.center = CGPoint(x: self.borderView.frame.maxX, y: self.borderView.frame.maxY)
        }
    }
    
    internal func setupDefaultAttributes() {
        DispatchQueue.main.async {
            let stickerSingleTap = UITapGestureRecognizer(target: self, action: #selector(self.stickerViewSingleTap(_:)))
            self.addGestureRecognizer(stickerSingleTap)
                        
            // stickerBorder
            self.borderView = StickerBorderView(frame: self.bounds, isStickerViewActive: self.isStickerViewActive)
            self.addSubview(self.borderView)
            
            // deleteController
            let deleteControlImage = UIImage(named: "closeButton")
            let singleTap = UITapGestureRecognizer(target: self, action: #selector(self.singleTap(_:)))
            self.deleteController = StickerControllerView(image: deleteControlImage, gestureRecognizer: singleTap, isStickerViewActive: self.isStickerViewActive)
            self.addSubview(self.deleteController)

            // rotateController
            let resizingControlImage = UIImage(named: "rotateButton")
            let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(self.resizeTranslate(_:)))
            self.resizingController = StickerControllerView(image: resizingControlImage, gestureRecognizer: panResizeGesture, isStickerViewActive: self.isStickerViewActive)
            self.addSubview(self.resizingController)

            let pinchResizeGesture = UIPinchGestureRecognizer(target: self, action: #selector(self.pinch(_:)))
            pinchResizeGesture.delegate = self
            self.addGestureRecognizer(pinchResizeGesture)

            let rotateResizeGesture = UIRotationGestureRecognizer(target: self, action: #selector(self.rotate(_:)))
            rotateResizeGesture.delegate = self
            self.addGestureRecognizer(rotateResizeGesture)
            
            self.updateControlsPosition()

            self.deltaAngle = atan2(self.frame.origin.y + self.frame.height - self.center.y, self.frame.origin.x + self.frame.width - self.center.x)
            
        }
    }
    
    func switchControls(toState state: Bool, animated: Bool = false) {
        if animated {
            let controlAlpha: CGFloat = state ? 1 : 0
            UIView.animate(withDuration: 0.3, animations: {
                self.resizingController.alpha = controlAlpha
                self.deleteController.alpha = controlAlpha
                self.borderView.alpha = controlAlpha
            })
        } else {
            resizingController.isHidden = !state
            deleteController.isHidden = !state
            borderView.isHidden = !state
        }
    }
    
    // MARK: control버튼 제스처 관련 메서드
    @objc private func singleTap(_ sender: UIPanGestureRecognizer) {
        let close = sender.view
        if let _ = close {
            self.delegate.removeSticker(sticker: self)
        }
    }

    @objc private func resizeTranslate(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            enableTranslucency(state: true)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()

        } else if sender.state == .changed {
            resizeView(recognizer: sender)
            rotateView(with: deltaAngle, recognizer: sender)

        } else if sender.state == .ended {
            enableTranslucency(state: false)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()
            Task {
                await stickerUIDidChange()
            }
        }
        updateControlsPosition()
    }

    private func resizeView(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.location(in: self)
        guard let previousPoint = previousPoint else {
            return
        }
        let diagonal = sqrt(pow(point.x, 2) + pow(point.y, 2))
        let previousDiagonal = sqrt(pow(previousPoint.x, 2) + pow(previousPoint.y, 2))
        let totalRatio = pow(diagonal / previousDiagonal, 2)

        bounds = CGRect(x: 0, y: 0, width: bounds.size.width * totalRatio, height: bounds.size.height * totalRatio)
        self.previousPoint = recognizer.location(in: self)
    }

    private func rotateView(with deltaAngle: CGFloat?, recognizer: UIPanGestureRecognizer) {
        let angle = atan2(recognizer.location(in: superview).y - center.y,
                          recognizer.location(in: superview).x - center.x)

        if let deltaAngle = deltaAngle {
            let angleDiff = deltaAngle - angle
            transform = CGAffineTransformMakeRotation(-angleDiff)
        }
    }

    // MARK: 스티커 자체에 입력되는 제스처 관련 메서드
    @objc private func stickerViewSingleTap(_ sender: UITapGestureRecognizer) {
        guard !isStickerViewMode else { return }
        
        do {
            let isStickerViewActive = try self.isStickerViewActive.value()
            updateIsStickerViewActive(value: !isStickerViewActive)
        } catch {
            print(error)
        }
    }
    
    @objc private func pinch(_ sender: UIPinchGestureRecognizer) {
        
        guard let isStickerViewActive = try? self.isStickerViewActive.value(), isStickerViewActive == true else { return }
        
        if sender.state == .began {
            oldBounds = bounds
            enableTranslucency(state: true)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()
        } else if sender.state == .changed {
            bounds = CGRect(x: 0, y: 0, width: oldBounds.width * sender.scale,
                            height: oldBounds.height * sender.scale)
        } else if sender.state == .ended {
            oldBounds = bounds
            enableTranslucency(state: false)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()
            Task {
                await stickerUIDidChange()
            }
        }
        updateControlsPosition()
    }

    @objc private func rotate(_ sender: UIRotationGestureRecognizer) {
        
        guard let isStickerViewActive = try? self.isStickerViewActive.value(), isStickerViewActive == true else { return }

        if sender.state == .began {
            oldTransform = transform
            enableTranslucency(state: true)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()
        } else if sender.state == .changed {
            transform = CGAffineTransformRotate(oldTransform, sender.rotation)
        } else if sender.state == .ended {
            oldTransform = transform
            enableTranslucency(state: false)
            previousPoint = sender.location(in: self)
            setNeedsDisplay()
            Task {
                await stickerUIDidChange()
            }
        }
        updateControlsPosition()
        
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let isStickerViewActive = try? self.isStickerViewActive.value(), isStickerViewActive == true else { return }
        
        self.delegate.bringStickerToFront(sticker: self)
        enableTranslucency(state: true)

        let touch = touches.first
        if let touch = touch {
            touchStart = touch.location(in: superview)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {

        guard let isStickerViewActive = try? self.isStickerViewActive.value(), isStickerViewActive == true else { return }

        let touchLocation = touches.first?.location(in: self)
        if resizingController.frame.contains(touchLocation!) {
            return
        }

        guard let touch = touches.first?.location(in: superview) else { return }
        translateUsingTouchLocation(touchPoint: touch)
        touchStart = touch
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
     
        guard let isStickerViewActive = try? self.isStickerViewActive.value(), isStickerViewActive == true else { return }

        enableTranslucency(state: false)
        
        Task {
            await stickerUIDidChange()
        }
        
    }

    private func translateUsingTouchLocation(touchPoint: CGPoint) {
        if let touchStart = touchStart {
            center = CGPoint(x: center.x + touchPoint.x - touchStart.x, y: center.y + touchPoint.y - touchStart.y)
        }
    }

    private func enableTranslucency(state: Bool) {
        UIView.animate(withDuration: 0.1) {
            if state == true {
                self.alpha = 0.65
            } else {
                self.alpha = 1
            }
        }
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if resizingController.frame.contains(point) || deleteController.frame.contains(point) || bounds.contains(point) {

            for subview in subviews.reversed() {
                let convertedPoint = subview.convert(point, from: self)
                let hitTestView = subview.hitTest(convertedPoint, with: event)
                if hitTestView != nil {
                    return hitTestView
                }
            }
            return self
        }
        return nil
    }
}

extension StickerView: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer is (UIPinchGestureRecognizer) &&
            otherGestureRecognizer is (UIRotationGestureRecognizer) {
            return true
        } else {
            return false
        }
    }
    
}
