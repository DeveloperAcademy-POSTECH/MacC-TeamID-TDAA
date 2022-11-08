//
//  PageViewModeCollectionViewCell.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/11/08.
//

import UIKit

class PageViewModeCollectionViewCell: UICollectionViewCell {
    
    private let pageBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        
        return view
    }()
    
    let separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureSubView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        self.pageBackgroundView.subviews.forEach {
            $0.removeFromSuperview()
        }
    }
    
    private func configureSubView() {
        DispatchQueue.main.async {
            [self.pageBackgroundView, self.separatorView].forEach {
                self.contentView.addSubview($0)
            }
            
            self.pageBackgroundView.snp.makeConstraints { make in
                make.edges.equalTo(self.contentView)
            }
            
            self.separatorView.snp.makeConstraints { make in
                make.horizontalEdges.equalTo(self.contentView)
                make.centerY.equalTo(self.contentView.snp.bottom)
                make.height.equalTo(1)
            }
        }
    }
    
    func setStickerView(items: [Item]) {
        DispatchQueue.main.async {
            let stickerViews: [StickerView] = items.map { item in
                
                switch item.itemType {
                case .text:
                    return TextStickerView(item: item)
                case .image:
                    return ImageStickerView(item: item)
                case .sticker:
                    return StickerStickerView(item: item)
                case .location:
                    return MapStickerView(item: item)
                }
                
            }
            
            stickerViews.forEach { stickerView in
                stickerView.isStickerViewMode = true
                self.pageBackgroundView.addSubview(stickerView)
            }
        }
    }
}
