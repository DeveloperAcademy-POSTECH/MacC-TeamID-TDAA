//
//  ThumbnailConfigViewController.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/24.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class ThumbnailConfigViewController: UIViewController {
    private var disposeBag = DisposeBag()
    private let device: UIScreen.DeviceSize = UIScreen.getDevice()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attribute()
        layout()
    }
    
    let titleLabel = UILabel()
    let cancelButton = UIButton(type: .system)
    let doneButton = UIButton(type: .system)
    let divider = UIView()
    
    let previewView = ThumbnailPreviewView()
    let dayAlbumView = AlbumCollectionView()
    
    
    // MARK: - bind, attribute, layout methods
    func bind(_ viewModel: ThumbnailConfigViewModel) {
        
        self.previewView.bind(viewModel.previewViewModel)
        self.dayAlbumView.bind(viewModel.dayAlbumViewModel)
        
        self.cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        self.doneButton.rx.tap
            .bind(to: viewModel.doneButtonTapped)
            .disposed(by: disposeBag)
        
        self.dayAlbumView.rx.modelSelected(UIImage.self)
            .subscribe(onNext: { image in
                self.previewView.backImageView.image = image
            })
            .disposed(by: disposeBag)
        
        viewModel.dismiss
            .drive(onNext: { _ in self.dismiss(animated: true) })
            .disposed(by: disposeBag)
        
        viewModel.complete
            .drive(onNext: { _ in self.dismiss(animated: true) })
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        view.backgroundColor = UIColor.appBackgroundColor
        
        titleLabel.text = "섬네일 선택"
        titleLabel.textColor = .black
        titleLabel.font = device.diaryConfigTitleFont
        
        cancelButton.setTitle("취소", for: .normal)
        cancelButton.titleLabel?.font = device.diaryConfigButtonFont
        cancelButton.tintColor = .navigationbarColor
        
        doneButton.setTitle("완료", for: .normal)
        doneButton.titleLabel?.font = device.diaryConfigButtonFont
        doneButton.tintColor = .navigationbarColor
        
        divider.backgroundColor = UIColor.placeholderText
    }
    
    private func layout() {
        [titleLabel, cancelButton, doneButton, divider, previewView, dayAlbumView].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
        
        cancelButton.snp.makeConstraints {
            $0.left.equalToSuperview().inset(device.diaryConfigCancelButtonLeftInset)
            $0.height.equalTo(titleLabel)
            $0.top.equalTo(titleLabel)
        }
        
        doneButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(device.diaryConfigDoneButtonRightInset)
            $0.height.equalTo(titleLabel)
            $0.top.equalTo(titleLabel)
        }
        
        divider.snp.makeConstraints {
            $0.bottom.equalTo(titleLabel).offset(9)
            $0.width.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        previewView.snp.makeConstraints {
            $0.top.equalTo(divider.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(170)
        }
        
        dayAlbumView.snp.makeConstraints {
            $0.top.equalTo(previewView.snp.bottom).offset(20)
            $0.bottom.width.equalToSuperview()
            $0.height.lessThanOrEqualToSuperview()
        }
    }
}
