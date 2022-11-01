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
    init(mapItem: MKMapItem, appearPoint: CGPoint) {
        super.init(frame: mapLabel.frame)

        Task {
            let mapItemContents = await self.mapItemContents(mapItem: mapItem)
            self.stickerViewData = await StickerViewData(itemType: .location, contents: mapItemContents, appearPoint: appearPoint, defaultSize: CGSize(width: 100, height: 100), lastEditor: UserManager.shared.userUID)
            
            await self.setLocationView()
            await self.setLocationViewFrame()
            await self.stickerUIDidChange()
            await self.configureStickerViewData()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.locationView.convertViewToImageView())
                super.setupDefaultAttributes()
            }
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.setLocationView()
            await self.setLocationViewFrame()
            await self.stickerUIDidChange()
            await self.configureStickerViewData()
            
            DispatchQueue.main.async {
                super.setupContentView(content: self.locationView.convertViewToImageView())
                super.setupDefaultAttributes()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func mapItemContents(mapItem: MKMapItem) async -> [String] {
        let locationName = mapItem.name ?? ""
        let locationAddress = mapItem.placemark.title ?? ""
        let latitude = mapItem.placemark.coordinate.latitude.description
        let longitude = mapItem.placemark.coordinate.longitude.description
        let itemContents = [locationName, locationAddress, latitude, longitude]
        
        return itemContents
    }
    
    private func setLocationView() async {
        
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {
                let locationName = $0[0]
                let locationAddress = $0[1]
                
                self.locationNameLabel.text = locationName
                self.locationAddressLabel.text = locationAddress
            })
            .disposed(by: self.disposeBag)

    }
    
    private func setLocationViewFrame() async {
        DispatchQueue.main.async {
            [self.pinImageView, self.locationNameLabel, self.locationAddressLabel].forEach {
                self.locationView.addSubview($0)
            }
            self.pinImageView.frame = CGRect(origin: .init(x: 15, y: 18.5), size: .init(width: 25, height: 25))
            self.locationNameLabel.frame = CGRect(origin: .init(x: 55, y: 10), size: self.locationNameLabel.intrinsicContentSize)
            self.locationAddressLabel.frame = CGRect(origin: .init(x: 55, y: self.locationNameLabel.frame.maxY + 4), size: self.locationAddressLabel.intrinsicContentSize)
            
            let width = (self.locationNameLabel.frame.width < self.locationAddressLabel.frame.width) ? self.locationAddressLabel.frame.width : self.locationNameLabel.frame.width
            self.locationView.frame = CGRect(origin: .zero, size: .init(width: 70 + width, height: 60))
            
            self.frame.origin.x -= self.locationView.frame.width / 2
            self.frame.origin.y -= self.locationView.frame.height / 2
            self.frame.size = self.locationView.frame.size
        }
    }
}
