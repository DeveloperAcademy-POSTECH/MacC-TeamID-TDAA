//
//  MapStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//
import MapKit
import UIKit

class MapStickerView: StickerView {

    private let mapLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        
        return label
    }()
    
    /// StickerView를 새로 만듭니다.
    init(mapItem: MKMapItem) {
        super.init(frame: mapLabel.frame)

        DispatchQueue.main.async {
            self.initializeStickerViewData(itemType: .location)
            self.stickerViewData.item.contents = [mapItem.name ?? ""]
            self.setMapLabel()
            super.setupContentView(content: self.mapLabel.convertViewToImageView())
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item, isSubviewHidden: Bool) {
        super.init(frame: CGRect())

        DispatchQueue.main.async{
            self.stickerViewData = StickerViewData(item: item)
            self.setMapLabel()
            self.configureStickerViewData()
            super.setupContentView(content: self.mapLabel.convertViewToImageView())
            super.setupDefaultAttributes()
            self.subviewIsHidden = isSubviewHidden
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setMapLabel() {
        guard let mapString = super.stickerViewData.item.contents.first else { return }
        mapLabel.text = mapString
        mapLabel.frame = CGRect(origin: .zero, size: mapLabel.intrinsicContentSize)
        frame = CGRect(origin: .zero, size: mapLabel.intrinsicContentSize)
    }
}
