//
//  MapStickerView.swift
//  MacC-GoldenRatio
//
//  Created by 김상현 on 2022/10/05.
//
import RxCocoa
import RxSwift
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

        Task {
            self.stickerViewData = await StickerViewData(itemType: .location)
            await self.mapItemContents(mapItem: mapItem)
            await self.setLocationView()
            await self.setLocationViewFrame()
            await self.configureStickerViewData()
            
            super.setupContentView(content: self.locationView.convertViewToImageView())
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.setLocationView()
            await self.setLocationViewFrame()
            await self.configureStickerViewData()
            
            super.setupContentView(content: self.locationView.convertViewToImageView())
            super.setupDefaultAttributes()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mapItemContents(mapItem: MKMapItem) async {
        Task {
            let locationName = mapItem.name ?? ""
            let locationAddress = mapItem.placemark.title ?? ""
            let latitude = mapItem.placemark.coordinate.latitude.description
            let longitude = mapItem.placemark.coordinate.longitude.description
            let itemContents = [locationName, locationAddress, latitude, longitude]
            
            await self.stickerViewData?.updateContents(contents: itemContents)
        }
    }
    
    private func setLocationView() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(onNext: {
                let locationName = $0[0]
                let locationAddress = $0[1]
                
                self.locationNameLabel.text = locationName
                self.locationAddressLabel.text = locationAddress
            })
            .disposed(by: self.disposeBag)

    }
    
    private func setLocationViewFrame() async {
        [pinImageView, locationNameLabel, locationAddressLabel].forEach {
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
