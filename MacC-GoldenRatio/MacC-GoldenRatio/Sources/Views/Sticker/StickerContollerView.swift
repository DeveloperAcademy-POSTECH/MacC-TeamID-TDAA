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

    init(image: UIImage?, gestureRecognizer: UIGestureRecognizer, lastEditorObservable: Observable<String?>) {
        super.init(image: image)

        DispatchQueue.main.async {
            self.tintColor = .buttonColor
            self.addGestureRecognizer(gestureRecognizer)
            self.frame = CGRect(origin: .zero, size: self.myDevice.stickerControllerSize)

            self.layer.cornerRadius = self.frame.width / 2
            self.isUserInteractionEnabled = true
            self.contentMode = .scaleAspectFit
            
            self.bindLastEditorObservable(lastEditorObservable: lastEditorObservable)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func bindLastEditorObservable(lastEditorObservable: Observable<String?>) {
        lastEditorObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                
                switch $0 {
                case UserManager.shared.userUID:
                    self.isHidden = false

                case nil:
                    self.isHidden = true
                    
                default:
                    self.isHidden = true
                }

            })
            .disposed(by: disposeBag)
    }
}
