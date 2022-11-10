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
    private let placehloderText = "텍스트를 입력해주세요."

    var isTextStickerViewEditMode: BehaviorSubject<TextStickerViewMode> = BehaviorSubject(value: TextStickerViewMode.inActive)
    
    var editModeDefaultFrame: CGRect!

    private var textStickerDefaultPosition: (CGRect,CGAffineTransform)!

    private var textStickerEditTextModePosition: BehaviorSubject<(CGRect, CGAffineTransform)>!

    
    let textView: UITextView = {
        let textView = UITextView(frame: .init(origin: .zero, size: .init(width: 200, height: 40)))
        textView.backgroundColor = .clear
        textView.font = .navigationTitleFont
        textView.isEditable = false
        textView.isScrollEnabled = false
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
            await self.bindIsStickerViewActiveObservable()
            await self.bindTextStickerContents()

            await self.configureStickerViewData()
            await self.setTextStickerPositionObservables()
            await self.bindTextStickerPositionByTextStickerMode()
            await self.bindTextStickerDefaultPositionByStickerViewData()
            
            await self.bindTextStickerComponentByTextStickerEditMode()
            
            DispatchQueue.main.async {
                self.configureTextStickerConstraints()
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
            self.isTextStickerViewEditMode.onNext(TextStickerViewMode.editText)
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.bindIsStickerViewActiveObservable()
            await self.bindTextStickerContents()

            await self.configureStickerViewData()
            await self.setTextStickerPositionObservables()
            await self.bindTextStickerPositionByTextStickerMode()
            await self.bindTextStickerDefaultPositionByStickerViewData()

            await self.bindTextStickerComponentByTextStickerEditMode()
            
            DispatchQueue.main.async {
                self.configureTextStickerConstraints()
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func bindIsStickerViewActiveObservable() async {
        
        self.isStickerViewActive
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                if !$0 {
                    self.isTextStickerViewEditMode.onNext(TextStickerViewMode.inActive)
                } else {
                    self.isTextStickerViewEditMode.onNext(TextStickerViewMode.editUI)
                }
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private func setTextStickerPositionObservables() async {
        
        self.textStickerDefaultPosition = (self.frame, self.transform)
        
        var targetFrame = self.frame
        targetFrame.origin.x = self.defaultPosition.x - ( targetFrame.width / 2 )
        targetFrame.origin.y = self.defaultPosition.y - ( targetFrame.height / 2 )
        
        self.editModeDefaultFrame = targetFrame
        self.textStickerEditTextModePosition = BehaviorSubject(value: (targetFrame, CGAffineTransform.identity))
        
    }
    
    private func bindTextStickerPositionByTextStickerMode() async {
        Observable
            .combineLatest(isTextStickerViewEditMode, textStickerEditTextModePosition)
            .observe(on:MainScheduler.asyncInstance)
            .subscribe(onNext: {
                
                switch $0 {
                case .inActive:
                    let frame = CGRect(origin: self.textStickerDefaultPosition.0.origin, size: self.frame.size)
                    self.stickerViewData?.updateUIItem(frame: frame, bounds: self.bounds, transform: self.textStickerDefaultPosition.1)

                case .editUI:
                    break
                
                case .editText:
                    let bounds = CGRect(origin: self.bounds.origin, size: $1.0.size)
                    self.stickerViewData?.updateUIItem(frame: $1.0, bounds: bounds, transform: $1.1)
                }
                self.updateControlsPosition()
                
            })
            .disposed(by: self.disposeBag)
        
    }
    
    private func bindTextStickerDefaultPositionByStickerViewData() async {
        guard let stickerViewData = self.stickerViewData else { return }
        Observable
            .combineLatest(self.isTextStickerViewEditMode, stickerViewData.frameObservable, stickerViewData.transitionObservable)
            .observe(on:MainScheduler.asyncInstance)
            .subscribe(onNext: {
                
                switch $0 {
                case .editUI:
                    self.textStickerDefaultPosition = ($1, $2)
                default:
                    break
                }

            })
            .disposed(by: self.disposeBag)
    }

    private func bindTextStickerComponentByTextStickerEditMode() async {

        self.isTextStickerViewEditMode
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                switch $0 {
                case .editText:
                    self.textView.isEditable = true
                    self.textView.isUserInteractionEnabled = true
                    self.textView.becomeFirstResponder()
                    
                    self.textView.isHidden = false
                    self.textImageView.isHidden = true
                default:
                    self.textView.isEditable = false
                    self.textView.isUserInteractionEnabled = false
                    self.textView.resignFirstResponder()
                    
                    self.textView.isHidden = true
                    self.textImageView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
        
    }
    
    private func configureTextStickerConstraints() {
        self.textView.delegate = self
        
        self.addSubview(textView)
        self.textView.snp.makeConstraints { make in
            make.center.top.equalToSuperview()
        }
        
        self.addSubview(textImageView)
        self.textImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindTextStickerContents() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .map {
                if $0[0] == "" {
                    return self.placehloderText
                } else {
                    return $0[0]
                }
            }
            .subscribe(onNext: {
                self.textView.text = $0
                self.textImageView.image = $0.image()
            })
            .disposed(by: self.disposeBag)

    }
    
    override func stickerViewSingleTap(_ sender: UITapGestureRecognizer) {
        guard !isStickerViewMode else { return }

        self.isStickerViewActive
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                if $0 {
                    self.isTextStickerViewEditMode.onNext(TextStickerViewMode.editText)
                } else {
                    self.updateIsStickerViewActive(value: !$0)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
}

extension TextStickerView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == placehloderText {
            textView.text = ""
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text == "" {
            textView.text = placehloderText
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
            self.textStickerEditTextModePosition.onNext((editModeFrame, editModeTransform))
        }
    }
    
}
