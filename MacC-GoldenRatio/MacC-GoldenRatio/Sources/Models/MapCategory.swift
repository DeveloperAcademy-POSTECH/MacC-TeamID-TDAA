//
//  MapCategory.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/11/18.
//

import Foundation

struct Category {
	let imageName: String
	let category: String
}

enum MapCategory: String {
	case airport = "MKPOICategoryAirport"
	case amusementPark = "MKPOICategoryAmusementPark"
	case aquarium = "MKPOICategoryAquarium"
	case atm = "MKPOICategoryAtm"
	case bakery = "MKPOICategoryBakery"
	case bank = "MKPOICategoryBank"
	case beach = "MKPOICategoryBeach"
	case brewery = "MKPOICategoryBrewery"
	case cafe = "MKPOICategoryCafe"
	case campground = "MKPOICategoryCampground"
	case carRental = "MKPOICategoryCarRental"
	case evCharger = "MKPOICategoryEvCharger"
	case fireStation = "MKPOICategoryFireStation"
	case fitnessCenter = "MKPOICategoryFitnessCenter"
	case foodMarket = "MKPOICategoryFoodMarket"
	case gasStation = "MKPOICategoryGasStation"
	case hospital = "MKPOICategoryHospital"
	case hotel = "MKPOICategoryHotel"
	case laundry = "MKPOICategoryLaundry"
	case library = "MKPOICategoryLibrary"
	case marina = "MKPOICategoryMarina"
	case movieTheater = "MKPOICategoryMovieTheater"
	case museum = "MKPOICategoryMuseum"
	case nationalPark = "MKPOICategoryNationalPark"
	case nightlife = "MKPOICategoryNightlife"
	case park = "MKPOICategoryPark"
	case parking = "MKPOICategoryParking"
	case pharmacy = "MKPOICategoryPharmacy"
	case police = "MKPOICategoryPolice"
	case postOffice = "MKPOICategoryPostOffice"
	case publicTransport = "MKPOICategoryPublicTransport"
	case restaurant = "MKPOICategoryRestaurant"
	case restroom = "MKPOICategoryRestroom"
	case school = "MKPOICategorySchool"
	case stadium = "MKPOICategoryStadium"
	case store = "MKPOICategoryStore"
	case theater = "MKPOICategoryTheater"
	case university = "MKPOICategoryUniversity"
	case winery = "MKPOICategoryWinery"
	case zoo = "MKPOICategoryZoo"
	
	var category: Category {
		switch self {
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
			return Category(imageName: "defaultIcon", category: "")
		}
	}
}
