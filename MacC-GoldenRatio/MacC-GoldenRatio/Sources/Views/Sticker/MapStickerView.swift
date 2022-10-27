//
//  MapStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//
import MapKit
import SnapKit
import UIKit

class MapStickerView: StickerView {

    private let locationView: UIView = {
        let view = UIView()
        view.backgroundColor = .startDateColor
        view.layer.cornerRadius = 5
        
        return view
    }()

    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.tintColor = .darkgrayColor
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .darkgrayColor
        label.font = .labelTitleFont
        label.textAlignment = .left
        
        return label
    }()
    
    private let locationAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .calendarWeeklyGrayColor
        label.font = .labelSubTitleFont
        label.textAlignment = .left
        
        return label
    }()
    
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
            self.mapItemContents(mapItem: mapItem)
            self.setLocationView()
            self.setLocationViewFrame()
            super.setupContentView(content: self.locationView.convertViewToImageView())
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        DispatchQueue.main.async{
            self.stickerViewData = StickerViewData(item: item)
            self.setLocationView()
            self.setLocationViewFrame()
            self.configureStickerViewData()
            super.setupContentView(content: self.locationView.convertViewToImageView())
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mapItemContents(mapItem: MKMapItem) {
        let locationName = mapItem.name ?? ""
        let locationAddress = mapItem.placemark.title ?? ""
        let latitude = mapItem.placemark.coordinate.latitude.description
        let longitude = mapItem.placemark.coordinate.longitude.description
        
        self.stickerViewData.item.contents = [locationName, locationAddress, latitude, longitude]
    }
    
    private func setLocationView() {
        let item = super.stickerViewData.item
        let locationName = item.contents[0]
        let locationAddress = item.contents[1]

        locationNameLabel.text = locationName
        locationAddressLabel.text = locationAddress
    }
    
    private func setLocationViewFrame() {
        [pinImageView, locationNameLabel, locationAddressLabel].forEach{
            locationView.addSubview($0)
        }
        pinImageView.frame = CGRect(origin: .init(x: 15, y: 18.5), size: .init(width: 25, height: 25))
        locationNameLabel.frame = CGRect(origin: .init(x: 55, y: 10), size: locationNameLabel.intrinsicContentSize)
        locationAddressLabel.frame = CGRect(origin: .init(x: 55, y: locationNameLabel.frame.maxY + 4), size: locationAddressLabel.intrinsicContentSize)
        
        let width = (locationNameLabel.frame.width < locationAddressLabel.frame.width) ? locationAddressLabel.frame.width : locationNameLabel.frame.width
        locationView.frame = CGRect(origin: .zero, size: .init(width: 70 + width, height: 60))
        
        frame = CGRect(origin: .zero, size: locationView.frame.size)
    }
}
