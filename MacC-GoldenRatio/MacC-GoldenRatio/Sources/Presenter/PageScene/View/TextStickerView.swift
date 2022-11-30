//
//  TextStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

enum TextStickerViewMode {
    case inActive
    case editUI
    case editText
}

class TextStickerView: StickerView {
    let defaultPosition = CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height / 4)
    private let placehloderText = "LzPageTextPlaceholder".localized

    var editModeDefaultFrame: CGRect!

    var textStickerViewMode: BehaviorSubject<TextStickerViewMode> = BehaviorSubject(value: TextStickerViewMode.inActive)
    
    private var textStickerDefaultUI: (CGRect,CGAffineTransform)!

    private var textStickerEditTextModeUI: BehaviorSubject<(CGRect, CGAffineTransform)> = BehaviorSubject(value: (CGRect(), CGAffineTransform.identity))

    
    let textView: UITextView = {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 200, height: 40)))
        textView.font = .navigationTitleFont
        textView.backgroundColor = .clear
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        textView.isScrollEnabled = false
        
        return textView
    }()
    
    let textImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
    
    /// StickerView를 새로 만듭니다.
    init(appearPoint: CGPoint) {
        super.init(frame: textView.frame)
        
        self.configureNewStickerView()

        Task {
            var targetPosition = defaultPosition
            targetPosition.x -= 100
            targetPosition.y -= 20
            
            self.stickerViewData = await StickerViewData(itemType: .text, contents: [""], appearPoint: targetPosition, defaultSize: textView.frame.size)
            await self.configureStickerViewData()
            await self.bindTextStickerContents()

            await self.bindIsStickerViewActiveObservable()
            await self.bindTextStickerDefaultPositionByStickerViewData()
            await self.setTextStickerEditModePositionObservable()
            await self.bindTextStickerPositionByTextStickerMode()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
                self.configureTextStickerConstraints()
                self.bindTextView()
                Task {
                    await self.bindTextStickerComponentByTextStickerEditMode()
                    self.textStickerViewMode.onNext(TextStickerViewMode.editText)
                }
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()
            await self.bindTextStickerContents()

            await self.bindIsStickerViewActiveObservable()
            await self.bindTextStickerDefaultPositionByStickerViewData()
            await self.setTextStickerEditModePositionObservable()
            await self.bindTextStickerPositionByTextStickerMode()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
                self.configureTextStickerConstraints()
                self.bindTextView()
            }
            await self.bindTextStickerComponentByTextStickerEditMode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindTextStickerContents() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .map {
                return $0[0]
            }
            .subscribe(onNext: {
                self.textView.text = $0
                
                if $0 == self.placehloderText {
                    self.textView.textColor = .calendarWeeklyGrayColor
                } else {
                    self.textView.textColor = .black
                }
                
                var attributes: [NSAttributedString.Key: Any] = [.font: UIFont.navigationTitleFont, .foregroundColor: UIColor.black]
                if self.textView.text == self.placehloderText {
                    attributes[.foregroundColor] = UIColor.gray
                }
                self.textImageView.image = $0.image(withAttributes: attributes)
            })
            .disposed(by: self.disposeBag)

    }
    
    private func bindIsStickerViewActiveObservable() async {
        
        self.isStickerViewActive
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                if !$0 {
                    self.textStickerViewMode.onNext(TextStickerViewMode.inActive)
                } else {
                    self.textStickerViewMode.onNext(TextStickerViewMode.editUI)
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private func bindTextStickerDefaultPositionByStickerViewData() async {
        guard let stickerViewData = self.stickerViewData else { return }
        
        // just 초기화
        Observable
            .combineLatest(stickerViewData.frameObservable, stickerViewData.transitionObservable)
            .observe(on:MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                self.textStickerDefaultUI = ($0, $1)
                
            })
            .disposed(by: self.disposeBag)
        
        Observable
            .combineLatest(self.textStickerViewMode, stickerViewData.frameObservable, stickerViewData.transitionObservable)
            .observe(on:MainScheduler.instance)
            .subscribe(onNext: {
                
                switch $0 {
                case .editUI:
                    self.textStickerDefaultUI = ($1, $2)
                default:
                    break
                }

            })
            .disposed(by: self.disposeBag)
    }
    
    private func setTextStickerEditModePositionObservable() async {
        self.stickerViewData?.frameObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                var targetFrame = $0
                targetFrame.origin.x = self.defaultPosition.x - ( targetFrame.width / 2 )
                targetFrame.origin.y = self.defaultPosition.y - ( targetFrame.height / 2 )
                self.editModeDefaultFrame = targetFrame
                self.textStickerEditTextModeUI.onNext((targetFrame, CGAffineTransform.identity))
            })
            .disposed(by: self.disposeBag)
    }
    
    private func bindTextStickerPositionByTextStickerMode() async {
        Observable
            .combineLatest(textStickerViewMode, textStickerEditTextModeUI)
            .observe(on:MainScheduler.instance)
            .subscribe(onNext: {
                
                switch $0 {
                case .inActive:
                    let frame = CGRect(origin: self.textStickerDefaultUI.0.origin, size: self.frame.size)
                    self.stickerViewData?.updateUIItem(frame: frame, bounds: self.bounds, transform: self.textStickerDefaultUI.1)
                case .editText:
                    let bounds = CGRect(origin: self.bounds.origin, size: $1.0.size)
                    self.stickerViewData?.updateUIItem(frame: $1.0, bounds: bounds, transform: $1.1)
                case .editUI:
                    break
                }
                
                self.updateControlsPosition()
                
            })
            .disposed(by: self.disposeBag)
        
    }

    private func bindTextStickerComponentByTextStickerEditMode() async {

        self.textStickerViewMode
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                switch $0 {
                case .editText:
                    self.textView.isEditable = true
                    self.textView.isSelectable = true
                    self.textView.isUserInteractionEnabled = true
                    self.textView.isExclusiveTouch = true
                    
                    self.textView.isHidden = false
                    self.textImageView.isHidden = true

                    super.enableTranslucency(state: false)
                    super.borderView?.backgroundColor = .white
                    super.deleteController?.isHidden = true
                    super.resizingController?.isHidden = true
                    self.textView.becomeFirstResponder()

                default:
                    self.textView.isEditable = false
                    self.textView.isSelectable = false
                    self.textView.isUserInteractionEnabled = false
                    self.textView.isExclusiveTouch = false
                    
                    super.borderView?.backgroundColor = .clear
                    self.textView.isHidden = true
                    self.textImageView.isHidden = false
                    self.textView.resignFirstResponder()
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func bindTextView() {
       
    }
    
    private func configureTextStickerConstraints() {
        DispatchQueue.main.async {
            self.textView.delegate = self
            
            self.borderView.addSubview(self.textView)
            self.textView.snp.makeConstraints { make in
                make.edges.equalTo(self)
            }
            
            self.addSubview(self.textImageView)
            self.textImageView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }
    }
    
    // Override Gesture Event Method
    override func stickerViewSingleTap(_ sender: UITapGestureRecognizer) {
        guard !isStickerViewMode else { return }

        self.isStickerViewActive
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                if $0 {
                    self.textStickerViewMode.onNext(TextStickerViewMode.editText)
                } else {
                    self.updateIsStickerViewActive(value: !$0)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    override func pinch(_ sender: UIPinchGestureRecognizer) {
        self.textStickerViewMode
            .take(1)
            .subscribe {
                guard $0 == .editUI else { return }
                super.pinch(sender)
            }
            .disposed(by: self.disposeBag)
    }
    
    override func rotate(_ sender: UIRotationGestureRecognizer) {
        self.textStickerViewMode
            .take(1)
            .subscribe {
                guard $0 == .editUI else { return }
                super.rotate(sender)
            }
            .disposed(by: self.disposeBag)
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textStickerViewMode
            .take(1)
            .subscribe {
                guard $0 == .editUI else { return }
                super.touchesBegan(touches, with: event)
            }
            .disposed(by: self.disposeBag)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textStickerViewMode
            .take(1)
            .subscribe {
                guard $0 == .editUI else { return }
                super.touchesMoved(touches, with: event)
            }
            .disposed(by: self.disposeBag)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.textStickerViewMode
            .take(1)
            .subscribe {
                guard $0 == .editUI else { return }
                super.touchesEnded(touches, with: event)
            }
            .disposed(by: self.disposeBag)
    }
}

extension TextStickerView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            if textView.text == self.placehloderText {
                self.stickerViewData?.updateContents(contents: [""])
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            DispatchQueue.main.async {
                let textView = UITextView()
                textView.font = .navigationTitleFont
                textView.text = self.placehloderText
                
                let size = CGSize(width: 2000, height: 2000)
                let estimatedSize = textView.sizeThatFits(size)
                
                let editModePositionX = self.defaultPosition.x - estimatedSize.width / 2
                let editModePositionY = self.defaultPosition.y - estimatedSize.height / 2
                let editModePosition = CGPoint(x: editModePositionX, y: editModePositionY)
                let editModeTransform = self.transform
                
                let editModeFrame = CGRect(origin: editModePosition, size: estimatedSize)
                
                self.stickerViewData?.updateContents(contents: [self.placehloderText])
                self.textStickerEditTextModeUI.onNext((editModeFrame, editModeTransform))
            }
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        DispatchQueue.main.async {
            let size = CGSize(width: 2000, height: 2000)
            let estimatedSize = textView.sizeThatFits(size)
            
            let editModePositionX = self.defaultPosition.x - estimatedSize.width / 2
            let editModePositionY = self.defaultPosition.y - estimatedSize.height / 2
            let editModePosition = CGPoint(x: editModePositionX, y: editModePositionY)
            let editModeTransform = self.transform
            
            let editModeFrame = CGRect(origin: editModePosition, size: estimatedSize)
            
            self.stickerViewData?.updateContents(contents: [self.textView.text])
            self.textStickerEditTextModeUI.onNext((editModeFrame, editModeTransform))
        }
    }
    
}
