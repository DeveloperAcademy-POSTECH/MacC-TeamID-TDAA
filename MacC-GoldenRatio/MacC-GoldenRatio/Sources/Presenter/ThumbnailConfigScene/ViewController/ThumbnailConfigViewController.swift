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
    func bind(_ viewModel: ThumbnailConfigViewModel){
        
        self.previewView.bind(viewModel.previewViewModel)
        self.dayAlbumView.bind(viewModel.dayAlbumViewModel)
        
        self.cancelButton.rx.tap
            .bind(to: viewModel.cancelButtonTapped)
            .disposed(by: disposeBag)
        
        self.doneButton.rx.tap
            .map {
                for index in 0..<self.dayAlbumView.visibleCells.count {
                    guard let cell = self.dayAlbumView.cellForItem(at: IndexPath(row: index, section: 0)) as? MyAlbumCollectionViewCell else { return }
                    if cell.imageView.image == self.previewView.backImageView.image {
                        viewModel.selectedIndex.accept(index)
                        break
                    }
                }
            }
            .bind(to: viewModel.doneButtonTapped)
            .disposed(by: disposeBag)
        
        self.dayAlbumView.rx.modelSelected(UIImage.self)
            .subscribe(onNext: { image in
                self.previewView.backImageView.image = image
            })
            .disposed(by: disposeBag)
        
        self.dayAlbumView.rx.itemSelected
            .subscribe(onNext: { index in
                viewModel.selectedIndex.accept(index.row)
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
        view.backgroundColor = UIColor.beige100
        
        titleLabel.text = "LzThumbnailSelect".localized
        titleLabel.textColor = .black
        titleLabel.font = .body
        
        cancelButton.setTitle("LzCreate".localized, for: .normal)
        cancelButton.titleLabel?.font = .body
        cancelButton.tintColor = .beige600
        
        doneButton.setTitle("LzDone".localized, for: .normal)
        doneButton.titleLabel?.font = .body
        doneButton.tintColor = .beige600
        
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
            $0.left.equalToSuperview().inset(Layout.diaryConfigCancelButtonLeftInset)
            $0.height.equalTo(titleLabel)
            $0.top.equalTo(titleLabel)
        }
        
        doneButton.snp.makeConstraints {
            $0.right.equalToSuperview().inset(Layout.diaryConfigDoneButtonRightInset)
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
