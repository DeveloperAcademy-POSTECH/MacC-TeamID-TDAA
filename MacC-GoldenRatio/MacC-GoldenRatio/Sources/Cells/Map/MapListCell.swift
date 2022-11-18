//
//  MapListCell.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/09.
//
import SnapKit
import UIKit

class MapListCell: UICollectionViewCell {
	private let myDevice = UIScreen.getDevice()
	private lazy var titleLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 22)
		label.textColor = .black
		return label
	}()
	
	private lazy var categoryImageView: UIImageView = {
		let imageView =  UIImageView()
		return imageView
	}()
	
	private lazy var categoryLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 15)
		label.textColor = .gray
		return label
	}()
	
	private lazy var addressLabel: UILabel = {
		let label =  UILabel()
		label.font = UIFont(name: "EF_Diary", size: 17)
		label.textColor = .gray
		label.numberOfLines = 2
		return label
	}()
	
	private lazy var lineView: UIView = {
		let view = UIView()
		view.backgroundColor = .placeholderText
		
		return view
	}()
	
	func setup(location: Location) {
		[titleLabel, categoryImageView, categoryLabel, addressLabel, lineView].forEach { self.addSubview($0) }
		
		let mapCategory = MapCategory(rawValue: location.locationCategory ?? "")
		let category = getCategory(mapCategory ?? MapCategory.def)
		
		categoryImageView.image = UIImage(named: category.imageName)
		categoryImageView.snp.makeConstraints {
			$0.width.height.equalTo(80)
			$0.top.equalToSuperview().inset(6)
			$0.leading.equalToSuperview()
		}
		
		titleLabel.text = location.locationName
		titleLabel.snp.makeConstraints {
			$0.height.equalTo(21)
			$0.top.equalToSuperview().inset(11.5)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
		}
		
		categoryLabel.text = category.category
		categoryLabel.snp.makeConstraints {
			$0.height.equalTo(13)
			$0.top.equalTo(titleLabel.snp.bottom).offset(10)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
		}
		
		addressLabel.text = location.locationAddress
		addressLabel.snp.makeConstraints {
			$0.height.equalTo(15)
			$0.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.leading.equalTo(categoryImageView.snp.trailing).offset(15)
			$0.bottom.equalToSuperview().inset(11.5)
		}
		
		lineView.snp.makeConstraints {
			$0.height.equalTo(1)
			$0.leading.trailing.equalTo(self.safeAreaLayoutGuide)
			$0.bottom.equalToSuperview()
		}
	}
	
	func getCategory(_ mapCategory: MapCategory) -> Category {
		switch mapCategory {
		case .airport:
			return Category(imageName: "airport", category: "공항")
		case .amusementPark:
			return Category(imageName: "amusementPark", category: "놀이공원")
		case .aquarium:
			return Category(imageName: "aquarium", category: "아쿠아리움")
		case .atm:
			return Category(imageName: "atm", category: "ATM")
		case .bakery:
			return Category(imageName: "bakery", category: "베이커리")
		case .bank:
			return Category(imageName: "bank", category: "은행")
		case .beach:
			return Category(imageName: "beach", category: "해변")
		case .brewery:
			return Category(imageName: "brewery", category: "맥주 공장")
		case .cafe:
			return Category(imageName: "cafe", category: "카페")
		case .campground:
			return Category(imageName: "campground", category: "캠핑장")
		case .carRental:
			return Category(imageName: "carRental", category: "렌트카")
		case .evCharger:
			return Category(imageName: "evCharger", category: "전기차 충전소")
		case .fireStation:
			return Category(imageName: "fireStation", category: "소방서")
		case .fitnessCenter:
			return Category(imageName: "fitnessCenter", category: "헬스장")
		case .foodMarket:
			return Category(imageName: "foodMarket", category: "푸드코드")
		case .gasStation:
			return Category(imageName: "gasStation", category: "주유소")
		case .hospital:
			return Category(imageName: "hospital", category: "병원")
		case .hotel:
			return Category(imageName: "hotel", category: "호텔")
		case .laundry:
			return Category(imageName: "laundry", category: "세탁")
		case .library:
			return Category(imageName: "library", category: "도서관")
		case .marina:
			return Category(imageName: "marina", category: "선착장")
		case .movieTheater:
			return Category(imageName: "movieTheater", category: "영화관")
		case .museum:
			return Category(imageName: "museum", category: "박물관")
		case .nationalPark:
			return Category(imageName: "nationalPark", category: "국립공원")
		case .nightlife:
			return Category(imageName: "nightlife", category: "유흥업소")
		case .park:
			return Category(imageName: "park", category: "공원")
		case .parking:
			return Category(imageName: "parking", category: "주차")
		case .pharmacy:
			return Category(imageName: "pharmacy", category: "약국")
		case .police:
			return Category(imageName: "police", category: "경찰서")
		case .postOffice:
			return Category(imageName: "postOffice", category: "우체국")
		case .publicTransport:
			return Category(imageName: "publicTransport", category: "대중교통")
		case .restaurant:
			return Category(imageName: "restaurant", category: "음식점")
		case .restroom:
			return Category(imageName: "restroom", category: "화장실")
		case .school:
			return Category(imageName: "school", category: "학교")
		case .stadium:
			return Category(imageName: "stadium", category: "경기장")
		case .store:
			return Category(imageName: "store", category: "상점")
		case .theater:
			return Category(imageName: "theater", category: "공연장")
		case .university:
			return Category(imageName: "university", category: "대학교")
		case .winery:
			return Category(imageName: "winery", category: "양조장")
		case .zoo:
			return Category(imageName: "zoo", category: "동물원")
		default:
			return Category(imageName: "zoo", category: "")
		}
	}
}
