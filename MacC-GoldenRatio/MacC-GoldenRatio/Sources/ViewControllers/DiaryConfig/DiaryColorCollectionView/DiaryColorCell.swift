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
    private var disposeBag = DisposeBag()
    private var cellVM = DiaryColorCellViewModel()
    var colorBezier = UIBezierPath()
    let shapeLayer = CAShapeLayer()
    
    lazy var simpleview: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        attribute(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    private func attribute(frame: CGRect) {
        self.backgroundColor = .black
        contentView.addSubview(simpleview)
        
//        simpleview.snp.makeConstraints{
//            $0.size.equalToSuperview().inset(5)
//            $0.center.equalToSuperview()
//        }
    }
}
