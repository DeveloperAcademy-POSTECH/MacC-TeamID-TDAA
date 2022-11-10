//
//  DiaryColorCollectionView.swift
//  MacC-GoldenRatio
//
//  Created by DongKyu Kim on 2022/11/07.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class DiaryColorCollectionView: UICollectionView {
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.estimatedItemSize = CGSize(width: 28, height: 28)
        flowLayout.scrollDirection = .horizontal
        
        self.collectionViewLayout = layout
        self.backgroundColor = UIColor.clear
        self.register(DiaryColorCell.self, forCellWithReuseIdentifier: "DiaryColorCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: DiaryColorCollectionViewModel) {
        
        viewModel.cellData
            .observe(on: MainScheduler.instance)
            .bind(to: self.rx.items(cellIdentifier: "DiaryColorCell", cellType: DiaryColorCell.self)) { index, state, cell in
                let cellColor = viewModel.colors[index]
                //cell.backgroundColor = UIColor(named: cellColor)
                cell.simpleview.backgroundColor = state ? .white : .darkgrayColor
            }
            .disposed(by: disposeBag)
        

        self.rx.itemSelected
            .subscribe(onNext: { indexPath in
                print(indexPath.item)
            })
            .disposed(by: disposeBag)
        
//            .map { $0.item }
//            .bind(to: viewModel.itemSelected)
//            .disposed(by: disposeBag)
    }
}



