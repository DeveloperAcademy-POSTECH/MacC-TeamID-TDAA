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
        view.backgroundColor = .beige500
        view.layer.cornerRadius = 5
        
        return view
    }()

    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "mappin.and.ellipse")
        imageView.tintColor = .gray500
        imageView.contentMode = .scaleAspectFit

        return imageView
    }()
    
    private let locationNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray500
        label.font = .title4
        label.textAlignment = .left
        
        return label
    }()
    
    private let locationAddressLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray400
        label.font = .caption2
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

        self.configureNewStickerView()
        
        Task {
            let mapItemContents = await self.mapItemContents(mapItem: mapItem)
            self.stickerViewData = await StickerViewData(itemType: .location, contents: mapItemContents, appearPoint: appearPoint, defaultSize: CGSize(width: 100, height: 100))
            await self.configureStickerViewData()

            self.setLocationView(appearPoint: appearPoint)
            self.stickerViewData?.updateUIItem(frame: self.frame, bounds: self.bounds, transform: self.transform)

            self.locationView.convertViewToImageView {
                super.setupContentView(content: $0)
            }
            super.setupDefaultAttributes()
        }
    }
    
    /// DB에서 StickerView를 불러옵니다.
    init(item: Item) {
        super.init(frame: CGRect())

        Task {
            self.stickerViewData = await StickerViewData(item: item)
            await self.configureStickerViewData()

            self.setLocationView(appearPoint: nil)
            
            self.locationView.convertViewToImageView {
                super.setupContentView(content: $0)
            }
            super.setupDefaultAttributes()
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
		let category = mapItem.pointOfInterestCategory?.rawValue.description ?? ""
		let itemContents = [locationName, locationAddress, latitude, longitude, category]
        return itemContents
    }
    
    // 새로 추가된 지도스티커의 경우 초기 생성 좌표 필요.
    private func setLocationView(appearPoint: CGPoint?) {
        self.stickerViewData?.contentsObservable
            .observe(on: MainScheduler.instance)
            .take(1)
            .subscribe(onNext: {
                let locationName = $0[0]
                let locationAddress = $0[1]
                
                self.locationNameLabel.text = locationName
                self.locationAddressLabel.text = locationAddress
                
                [self.pinImageView, self.locationNameLabel, self.locationAddressLabel].forEach {
                    self.locationView.addSubview($0)
                }
                self.pinImageView.frame = CGRect(origin: .init(x: 15, y: 18.5), size: .init(width: 25, height: 25))
                self.locationNameLabel.frame = CGRect(origin: .init(x: 55, y: 10), size: self.locationNameLabel.intrinsicContentSize)
                self.locationAddressLabel.frame = CGRect(origin: .init(x: 55, y: self.locationNameLabel.frame.maxY + 4), size: self.locationAddressLabel.intrinsicContentSize)
                
                let width = (self.locationNameLabel.frame.width < self.locationAddressLabel.frame.width) ? self.locationAddressLabel.frame.width : self.locationNameLabel.frame.width
                self.locationView.bounds = CGRect(origin: .zero, size: .init(width: 70 + width, height: 60))
                
                if let appearPoint = appearPoint {
                    self.frame.size = self.locationView.bounds.size
                    
                    self.frame.origin.x = appearPoint.x - ( self.locationView.bounds.width / 2 - 50 )
                    self.frame.origin.y = appearPoint.y - ( self.locationView.bounds.height / 2 - 50 )
                }
            })
            .disposed(by: self.disposeBag)
    }
}
