//
//  StickerBorderView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import RxSwift
import UIKit

/// StickerView의 테두리를 나타내는 사각형 뷰
class StickerBorderView: UIView {
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    private let disposeBag = DisposeBag()
    
    init(frame: CGRect, lastEditorObservable: Observable<String?>) {
        super.init(frame: frame)
        setupView()
        bindLastEditorObservable(lastEditorObservable: lastEditorObservable)
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setupView()
    }
    
    private func setupView() {
        backgroundColor = UIColor.clear
        layer.borderWidth = myDevice.stickerBorderWidth
        layer.borderColor = UIColor.buttonColor.cgColor
    }

    private func bindLastEditorObservable(lastEditorObservable: Observable<String?>) {
        lastEditorObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                
                switch $0 {
                case UserManager.shared.userUID:
                    self.isHidden = false
                    self.layer.borderColor = UIColor.buttonColor.cgColor

                case nil:
                    self.isHidden = true
                    self.layer.borderColor = UIColor.clear.cgColor
                    
                default:
                    self.isHidden = false
                    self.layer.borderColor = UIColor.red.cgColor

                }

            })
            .disposed(by: disposeBag)
    }
}
