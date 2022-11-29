//
//  StickerPickerCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//

import UIKit

class StickerPickerCollectionViewCell: UICollectionViewCell {

    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubviews()
        configureConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        contentView.addSubview(imageView)
    }
    
    private func configureConstraints() {
        imageView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.equalTo(imageView.snp.width)
        }
    }
    
    func setImage(_ image: UIImage){
        self.imageView.image = image
    }
}
