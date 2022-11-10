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
    var isTextStickerViewEditMode: BehaviorSubject<Bool> = BehaviorSubject(value: false)
    
    var editModeDefaultFrame: CGRect!
    
    private var textStickerViewEditModePosition: BehaviorSubject<(CGRect, CGAffineTransform)>!

    private var oldTextStickerViewPosition: BehaviorSubject<(CGRect,CGAffineTransform)>!

    private let placehloderText = "텍스트를 입력해주세요."
    
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
            self.stickerViewData = await StickerViewData(itemType: .text, contents: [""], appearPoint: appearPoint, defaultSize: textView.frame.size)
            await self.setTextStickerViewEditModeProperty()
            await self.setTextView()

            await self.configureStickerViewData()
            await self.setTextStickerViewFrame()
            await self.setTextViewUIObservable()
            
            await self.bindIsTextStickerViewActive()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: textView.frame)

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.setTextStickerViewEditModeProperty()
            await self.setTextView()

            await self.configureStickerViewData()
            await self.setTextStickerViewFrame()
            await self.setTextViewUIObservable()

            await self.bindIsTextStickerViewActive()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.textView)
                super.setupDefaultAttributes()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setTextStickerViewEditModeProperty() async {
        
        self.isStickerViewActive
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                if !$0 {
                    self.isTextStickerViewEditMode.onNext($0)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
    private func setTextStickerViewFrame() async {
        self.oldTextStickerViewPosition = BehaviorSubject(value: (self.frame, self.transform))
        var targetFrame = self.frame
        targetFrame.origin.x = UIScreen.main.bounds.width / 2
        targetFrame.origin.y = UIScreen.main.bounds.height / 4
        
        self.editModeDefaultFrame = targetFrame
        self.textStickerViewEditModePosition = BehaviorSubject(value: (targetFrame, CGAffineTransform.identity))
    }
    
    private func setTextViewUIObservable() async {
        Observable
            .combineLatest(isTextStickerViewEditMode, oldTextStickerViewPosition, textStickerViewEditModePosition)
            .observe(on:MainScheduler.asyncInstance)
            .subscribe(onNext: {
                if $0 {
                    let bounds = CGRect(origin: self.bounds.origin, size: $2.0.size)
                    
                    self.stickerViewData?.updateUIItem(frame: $2.0, bounds: bounds, transform: $2.1)
                } else {
                    let frame = CGRect(origin: $1.0.origin, size: self.frame.size)
                    let bounds = CGRect(origin: self.bounds.origin, size: self.frame.size)
                    
                    self.stickerViewData?.updateUIItem(frame: frame, bounds: bounds, transform: $1.1)
                }
                
                self.updateControlsPosition()
            })
            .disposed(by: self.disposeBag)

    }

    private func bindIsTextStickerViewActive() async {

        self.isTextStickerViewEditMode
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                self.textView.isEditable = $0
                self.textView.isUserInteractionEnabled = $0
                
                if $0 {
                    self.textView.becomeFirstResponder()
                    self.textView.isHidden = false
                    self.textImageView.isHidden = true
                } else {
                    self.textView.resignFirstResponder()
                    self.textView.isHidden = true
                    self.textImageView.isHidden = false
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func setTextView() async {
        
        self.textView.delegate = self
        
        self.addSubview(textView)
        self.textView.snp.makeConstraints { make in
            make.center.top.equalToSuperview()
        }
        
        self.addSubview(textImageView)
        self.textImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
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
                    self.isTextStickerViewEditMode.onNext($0)
                } else {
                    self.updateIsStickerViewActive(value: !$0)
                }
            })
            .disposed(by: self.disposeBag)
    }
    
}

extension String {
    
    /// Generates a `UIImage` instance from this string using a specified
    /// attributes and size.
    ///
    /// - Parameters:
    ///     - attributes: to draw this string with. Default is `nil`.
    ///     - size: of the image to return.
    /// - Returns: a `UIImage` instance from this string using a specified
    /// attributes and size, or `nil` if the operation fails.
    func image(withAttributes attributes: [NSAttributedString.Key: Any]? = nil, size: CGSize? = nil) -> UIImage? {
        let size = size ?? (self as NSString).size(withAttributes: attributes)
        return UIGraphicsImageRenderer(size: size).image { _ in
            (self as NSString).draw(in: CGRect(origin: .zero, size: size),
                                    withAttributes: attributes)
        }
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
            
            let editModePositionX = self.editModeDefaultFrame.minX - estimatedSize.width / 2
            let editModePositionY = self.editModeDefaultFrame.minY - estimatedSize.height / 2
            let editModePosition = CGPoint(x: editModePositionX, y: editModePositionY)
            let editModeTransform = self.transform
            
            let editModeFrame = CGRect(origin: editModePosition, size: estimatedSize)
            
            self.stickerViewData?.updateContents(contents: [self.textView.text])
            self.textStickerViewEditModePosition.onNext((editModeFrame, editModeTransform))
        }
    }
    
}
