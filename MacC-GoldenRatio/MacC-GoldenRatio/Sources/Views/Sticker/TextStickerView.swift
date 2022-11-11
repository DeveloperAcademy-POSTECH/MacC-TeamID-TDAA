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
    private let placehloderText = "텍스트를 입력해주세요"

    var editModeDefaultFrame: CGRect!

    var textStickerViewMode: BehaviorSubject<TextStickerViewMode> = BehaviorSubject(value: TextStickerViewMode.inActive)
    
    private var textStickerDefaultUI: (CGRect,CGAffineTransform)!

    private var textStickerEditTextModeUI: BehaviorSubject<(CGRect, CGAffineTransform)> = BehaviorSubject(value: (CGRect(), CGAffineTransform.identity))

    
    let textView: UITextView = {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 200, height: 40)))
        textView.backgroundColor = .clear
        textView.font = .navigationTitleFont
        textView.isEditable = false
        textView.isUserInteractionEnabled = false
        
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
            }
            await self.bindTextStickerComponentByTextStickerEditMode()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindTextStickerContents() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.asyncInstance)
            .map {
                if $0[0] == "" {
                    return self.placehloderText
                } else {
                    return $0[0]
                }
            }
            .subscribe(onNext: {
                self.textView.text = $0
                
                let attributes: [NSAttributedString.Key: Any] = [.font: UIFont.navigationTitleFont]
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
            .observe(on:MainScheduler.asyncInstance)
            .take(1)
            .subscribe(onNext: {
                self.textStickerDefaultUI = ($0, $1)
                
            })
            .disposed(by: self.disposeBag)
        
        Observable
            .combineLatest(self.textStickerViewMode, stickerViewData.frameObservable, stickerViewData.transitionObservable)
            .observe(on:MainScheduler.asyncInstance)
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
            .observe(on: MainScheduler.asyncInstance)
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
            .observe(on:MainScheduler.asyncInstance)
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
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                switch $0 {
                case .editText:
                    self.textView.isEditable = true
                    self.textView.isSelectable = true
                    self.textView.isUserInteractionEnabled = true
                    self.textView.isExclusiveTouch = true
                    
                    self.textView.becomeFirstResponder()
                    self.textView.isHidden = false
                    self.textImageView.isHidden = true

                    super.enableTranslucency(state: false)
                    guard let deleteController = super.deleteController, let resizingController = super.resizingController else { return }
                    deleteController.isHidden = true
                    resizingController.isHidden = true

                default:
                    self.textView.isEditable = false
                    self.textView.isSelectable = false
                    self.textView.isUserInteractionEnabled = false
                    self.textView.isExclusiveTouch = false

                    self.textView.resignFirstResponder()
                    self.textView.isHidden = true
                    self.textImageView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
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
                textView.text = ""
            }
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        DispatchQueue.main.async {
            if textView.text == "" {
                textView.text = self.placehloderText
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
