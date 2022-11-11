//
//  DiaryDaysCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/10.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class DiaryDaysCollectionView: UICollectionView {
    
    private let disposeBag = DisposeBag()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        super.init(frame: frame, collectionViewLayout: layout)

        attribute()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: DiaryDaysCollectionViewModel) {
        viewModel.cellData
            .observe(on: MainScheduler.instance)
            .bind(to: self.rx.items(cellIdentifier: DiaryDaysCell.identifier, cellType: DiaryDaysCell.self)) { index, data, cell in
                cell.dayLabel.text = data.dayLabel
                cell.dateLabel.text = data.dateLabel
                cell.backImageView.image = data.image
                cell.gradientLayer.isHidden = (data.image == UIImage(named: "diaryDaysDefault")) ? true : false
            }
            .disposed(by: disposeBag)
    }
    
    private func attribute() {
        self.register(DiaryDaysCell.self, forCellWithReuseIdentifier: DiaryDaysCell.identifier)
        self.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.backgroundColor = .clear
    }
}

extension DiaryDaysCollectionView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = UIScreen.main.bounds.width
        return CGSize(width: width, height: 190)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForItemAt section: Int) -> CGFloat {
        return 0
    }
}

