//
//  MapStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//
import MapKit
import UIKit

class MapStickerView: StickerView {
    private var mapItem: MKMapItem?

    init(mapItem: MKMapItem, size:CGSize) {
        self.mapItem = mapItem
        let mapLabel = UILabel()
        mapLabel.text = mapItem.name
        mapLabel.textColor = .label
        mapLabel.textAlignment = .center
        mapLabel.frame = CGRect(origin: .zero, size: mapLabel.intrinsicContentSize)
        super.init(frame: mapLabel.frame)

        DispatchQueue.main.async {
            let mapImage = mapLabel.transformToImage()
            let mapImageView = UIImageView(image: mapImage)
            mapImageView.frame = mapLabel.frame
            super.setupContentView(content: mapImageView)
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
