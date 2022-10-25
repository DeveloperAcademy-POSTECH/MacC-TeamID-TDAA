//
//  StickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import MapKit
import SnapKit
import UIKit
import FirebaseAuth

protocol StickerViewDelegate {
    func removeSticker(sticker: StickerView)
    func bringToFront(sticker: StickerView)
    func updateStickerToDB()
}

class StickerView: UIView {
    var delegate: StickerViewDelegate!
    internal var stickerViewData: StickerViewData!
    internal let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()

    internal var touchStart: CGPoint?
    private var previousPoint: CGPoint?
    private var deltaAngle: CGFloat?

    private var resizingController: StickerControllerView!
    private var deleteController: StickerControllerView!
    private var borderView: StickerBorderView!

    private var oldBounds: CGRect!
    private var oldTransform: CGAffineTransform!
    
    var borderMode: BorderMode? = .me
    var isSubviewHidden = true {
        willSet {
            self.subviews.forEach{
                if $0 is StickerControllerView || $0 is StickerBorderView {
                    $0.isHidden = newValue
                }
            }
            if newValue {
                enableTranslucency(state: !newValue)
            }
        }
        didSet{
            print("update edits")
            self.updateEdits()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        DispatchQueue.main.async {
            self.setupDefaultAttributes()
        }
    }

    internal func initializeStickerViewData(itemType: ItemType) {
        let id = UUID().uuidString + String(Date().timeIntervalSince1970)
        let item = Item(itemUUID: id, itemType: itemType, contents: [], itemFrame: [], itemBounds: [], itemTransform: [])
        self.stickerViewData = StickerViewData(item: item)
    }

    /// StickerViewData 를 현재 View의 프로퍼티들에게 적용합니다.
    internal func configureStickerViewData() {
        guard let stickerViewData = self.stickerViewData else { return }
        self.frame = stickerViewData.fetchFrame()
        self.bounds = stickerViewData.fetchBounds()
        self.transform = stickerViewData.fetchTransform()
        guard let editor = stickerViewData.fetchCurrentEditor() else { return }
        if editor == Auth.auth().currentUser?.uid ?? "" {
            self.borderMode = .me
        } else {
            self.borderMode = .otherUser
        }
        self.isSubviewHidden = false
    }
    
    internal func setupContentView(content: UIView) {
        let contentView = UIView(frame: content.frame)
        contentView.backgroundColor = .clear
        contentView.addSubview(content)
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    internal func setBorderAttributes() {
        guard let borderMode = self.borderMode else { return }
        borderView.setBorderColor(borderMode: borderMode)
        switch borderMode {
        case .otherUser:
            self.subviews.forEach{
                $0.isUserInteractionEnabled = false
            }
        case .me:
            break
        }
    }
    
    internal func setupDefaultAttributes() {
        let stickerSingleTap = UITapGestureRecognizer(target: self, action: #selector(stickerViewSingleTap(_:)))
        addGestureRecognizer(stickerSingleTap)
        
        borderView = StickerBorderView(frame: bounds)
        addSubview(borderView)
        borderView.isHidden = isSubviewHidden

        let deleteControlImage = UIImage(systemName: "xmark.circle.fill")
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(singleTap(_:)))
        deleteController = StickerControllerView(image: deleteControlImage, gestureRecognizer: singleTap)
        addSubview(deleteController)
        deleteController.isHidden = isSubviewHidden

        let resizingControlImage = UIImage(systemName: "crop.rotate")
        let panResizeGesture = UIPanGestureRecognizer(target: self, action: #selector(resizeTranslate(_:)))
        resizingController = StickerControllerView(image: resizingControlImage, gestureRecognizer: panResizeGesture)
        addSubview(resizingController)
        resizingController.isHidden = isSubviewHidden

        let pinchResizeGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinch(_:)))
        pinchResizeGesture.delegate = self
        addGestureRecognizer(pinchResizeGesture)

        let rotateResizeGesture = UIRotationGestureRecognizer(target: self, action: #selector(rotate(_:)))
        rotateResizeGesture.delegate = self
        addGestureRecognizer(rotateResizeGesture)

        updateControlsPosition()

        deltaAngle = atan2(frame.origin.y + frame.height - center.y, frame.origin.x + frame.width - center.x)
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
    // 삭제 버튼 액션
    @objc private func singleTap(_ sender: UIPanGestureRecognizer) {
        let close = sender.view
        if let _ = close {
            guard let delegate = self.delegate else {return}
            delegate.removeSticker(sticker: self)
            delegate.updateStickerToDB()
        }
    }

    // crop 버튼 액션
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
            updateEdits()
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

    internal func updateControlsPosition() {
        let inset = myDevice.stickerBorderInset
        borderView.frame = CGRect(x: -inset, y: -inset, width: bounds.size.width + inset * 2,
                                  height: bounds.size.height + inset * 2)
        deleteController.center = CGPoint(x: borderView.frame.maxX, y: borderView.frame.origin.y)
        resizingController.center = CGPoint(x: borderView.frame.maxX, y: borderView.frame.maxY)
    }

    // MARK: 스티커 자체에 입력되는 제스처 관련 메서드
    @objc private func stickerViewSingleTap(_ sender: UITapGestureRecognizer) {
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        if isSubviewHidden == true {
            self.isSubviewHidden.toggle()
        }
    }
    
    @objc private func pinch(_ sender: UIPinchGestureRecognizer) {
        guard isSubviewHidden == false else { return }
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        
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
            updateEdits()
        }
        updateControlsPosition()
    }

    @objc private func rotate(_ sender: UIRotationGestureRecognizer) {
        guard isSubviewHidden == false else { return }
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        
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
            updateEdits()
        }
        updateControlsPosition()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isSubviewHidden == false else { return }
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        
        guard let delegate = self.delegate else {return}
        delegate.bringToFront(sticker: self)
        enableTranslucency(state: true)

        let touch = touches.first
        if let touch = touch {
            touchStart = touch.location(in: superview)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isSubviewHidden == false else { return }
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        
        let touchLocation = touches.first?.location(in: self)
        if resizingController.frame.contains(touchLocation!) {
            return
        }

        guard let touch = touches.first?.location(in: superview) else { return }
        translateUsingTouchLocation(touchPoint: touch)
        touchStart = touch
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isSubviewHidden == false else { return }
        guard let borderMode = self.borderMode else { return }
        guard borderMode == .me else { return }
        
        enableTranslucency(state: false)
        updateEdits()
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
    
    internal func updateEdits() {
        guard let stickerViewData = self.stickerViewData else { return }
        guard stickerViewData.updateItem(sticker: self) else { return }
        guard let delegate = self.delegate else { return }
        delegate.updateStickerToDB()
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
