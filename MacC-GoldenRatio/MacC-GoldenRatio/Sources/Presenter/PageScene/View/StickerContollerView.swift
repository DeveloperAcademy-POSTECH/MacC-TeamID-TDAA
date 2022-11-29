//
//  StickerContollerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/01.
//

import RxSwift
import UIKit


/// 스티커에 붙어있는 버튼  ex) 이동, 삭제 버튼
class StickerControllerView: UIImageView {
    private let myDevice: UIScreen.DeviceSize = UIScreen.getDevice()
    private let disposeBag = DisposeBag()

    init(image: UIImage?, gestureRecognizer: UIGestureRecognizer, isStickerViewActive: Observable<Bool>) {
        super.init(image: image)

        DispatchQueue.main.async {
            self.tintColor = .buttonColor
            self.addGestureRecognizer(gestureRecognizer)
            self.frame = CGRect(origin: .zero, size: self.myDevice.stickerControllerSize)

            self.layer.cornerRadius = self.frame.width / 2
            self.isUserInteractionEnabled = true
            self.contentMode = .scaleAspectFit
            
            self.bindLastEditorObservable(isStickerViewActive: isStickerViewActive)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindLastEditorObservable(isStickerViewActive: Observable<Bool>) {
        isStickerViewActive
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                
                if $0 {
                    self.isHidden = false
                } else {
                    self.isHidden = true
                }

            })
            .disposed(by: disposeBag)
    }
}
