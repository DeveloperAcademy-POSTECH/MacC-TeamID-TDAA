//
//  PageCollectionViewHeaderCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/12.
//

import UIKit
import SnapKit

final class PageCollectionViewHeaderCell: UICollectionReusableView {
    let view: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.separatorColor
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        self.addSubview(self.view)
        
        view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
