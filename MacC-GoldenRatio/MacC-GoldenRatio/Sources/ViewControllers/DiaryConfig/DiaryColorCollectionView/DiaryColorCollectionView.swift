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
        self.backgroundColor = UIColor.clear
        self.register(DiaryColorCell.self, forCellWithReuseIdentifier: "DiaryColorCell")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func bind(_ viewModel: DiaryColorCollectionViewModel) {
        
        viewModel.cellData
            .bind(to: self.rx.items(cellIdentifier: DiaryColorCell.identifier, cellType: DiaryColorCell.self)) { index, state, cell in
                let cellColor = viewModel.colors[index]
                cell.circleForeground.backgroundColor = UIColor(named: "\(cellColor)Color")
                Observable<Bool>
                    .just(state)
                    .bind(to: cell.cellViewModel.colorSelect)
                    .disposed(by: self.disposeBag)
            }
            .disposed(by: disposeBag)
        
        self.rx.itemSelected
            .map { $0.row }
            .bind(to: viewModel.itemSelected)
            .disposed(by: disposeBag)
        
        self.rx.didEndDisplayingCell
            .subscribe(onNext: { _, indexPath in
                guard let cell = self.dequeueReusableCell(withReuseIdentifier: DiaryColorCell.identifier, for: indexPath) as? DiaryColorCell else { return }
                    cell.disposeBag = DisposeBag()
            })
            .disposed(by: disposeBag)
    }
    
}

