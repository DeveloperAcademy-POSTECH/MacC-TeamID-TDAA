//
//  DiaryColorCell.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/07.
//

import RxSwift
import RxCocoa
import SnapKit
import UIKit

class DiaryColorCell: UICollectionViewCell {
    let identifier = "DiaryColorCell"
    var disposeBag = DisposeBag()
    let cellViewModel = DiaryColorCellViewModel()
    
    let checkImage = UIImageView(image: UIImage(systemName: "checkmark"))
    
    private lazy var circleBackground: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(patternImage: UIImage(named: "diaryInnerTexture.png") ?? UIImage())
        return view
    }()
    
    lazy var circleForeground: UIView = {
        let view = UIView()
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 0.2
        return view
    }()
    
    private lazy var circleBorer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.layer.borderColor = UIColor.black.cgColor
        view.layer.borderWidth = 1
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        bind()
        attribute(frame: frame)
    }
    
    private func bind() {
        cellViewModel.isSelected
            .emit(onNext: { isTrue in
                if !isTrue {
                    self.checkImage.isHidden = true
                    self.circleBorer.isHidden = true
                }
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func attribute(frame: CGRect) {
        self.checkImage.tintColor = .black
        
        [circleBackground, circleForeground, circleBorer].forEach {
            $0.layer.cornerRadius = frame.width / 2
            
            contentView.addSubview($0)
            
            $0.snp.makeConstraints {
                $0.size.equalTo(frame.size)
                $0.center.equalToSuperview()
            }
        }
        contentView.addSubview(checkImage)
        
        checkImage.snp.makeConstraints {
            $0.width.height.equalTo(17)
            $0.center.equalToSuperview()
        }
    }
}
