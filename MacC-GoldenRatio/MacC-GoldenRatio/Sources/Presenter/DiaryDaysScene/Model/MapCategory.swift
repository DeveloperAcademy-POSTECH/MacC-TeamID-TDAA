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
            return Category(imageName: "airport", category: self.rawValue.localized)
        case .amusementPark:
            return Category(imageName: "amusementPark", category: self.rawValue.localized)
        case .aquarium:
            return Category(imageName: "aquarium", category: self.rawValue.localized)
        case .atm:
            return Category(imageName: "atm", category: self.rawValue.localized)
        case .bakery:
            return Category(imageName: "bakery", category: self.rawValue.localized)
        case .bank:
            return Category(imageName: "bank", category: self.rawValue.localized)
        case .beach:
            return Category(imageName: "beach", category: self.rawValue.localized)
        case .brewery:
            return Category(imageName: "brewery", category: self.rawValue.localized)
        case .cafe:
            return Category(imageName: "cafe", category: self.rawValue.localized)
        case .campground:
            return Category(imageName: "campground", category: self.rawValue.localized)
        case .carRental:
            return Category(imageName: "carRental", category: self.rawValue.localized)
        case .evCharger:
            return Category(imageName: "evCharger", category: self.rawValue.localized)
        case .fireStation:
            return Category(imageName: "fireStation", category: self.rawValue.localized)
        case .fitnessCenter:
            return Category(imageName: "fitnessCenter", category: self.rawValue.localized)
        case .foodMarket:
            return Category(imageName: "foodMarket", category: self.rawValue.localized)
        case .gasStation:
            return Category(imageName: "gasStation", category: self.rawValue.localized)
        case .hospital:
            return Category(imageName: "hospital", category: self.rawValue.localized)
        case .hotel:
            return Category(imageName: "hotel", category: self.rawValue.localized)
        case .laundry:
            return Category(imageName: "laundry", category: self.rawValue.localized)
        case .library:
            return Category(imageName: "library", category: self.rawValue.localized)
        case .marina:
            return Category(imageName: "marina", category: self.rawValue.localized)
        case .movieTheater:
            return Category(imageName: "movieTheater", category: self.rawValue.localized)
        case .museum:
            return Category(imageName: "museum", category: self.rawValue.localized)
        case .nationalPark:
            return Category(imageName: "nationalPark", category: self.rawValue.localized)
        case .nightlife:
            return Category(imageName: "nightlife", category: self.rawValue.localized)
        case .park:
            return Category(imageName: "park", category: self.rawValue.localized)
        case .parking:
            return Category(imageName: "parking", category: self.rawValue.localized)
        case .pharmacy:
            return Category(imageName: "pharmacy", category: self.rawValue.localized)
        case .police:
            return Category(imageName: "police", category: self.rawValue.localized)
        case .postOffice:
            return Category(imageName: "postOffice", category: self.rawValue.localized)
        case .publicTransport:
            return Category(imageName: "publicTransport", category: self.rawValue.localized)
        case .restaurant:
            return Category(imageName: "restaurant", category: self.rawValue.localized)
        case .restroom:
            return Category(imageName: "restroom", category: self.rawValue.localized)
        case .school:
            return Category(imageName: "school", category: self.rawValue.localized)
        case .stadium:
            return Category(imageName: "stadium", category: self.rawValue.localized)
        case .store:
            return Category(imageName: "store", category: self.rawValue.localized)
        case .theater:
            return Category(imageName: "theater", category: self.rawValue.localized)
        case .university:
            return Category(imageName: "university", category: self.rawValue.localized)
        case .winery:
            return Category(imageName: "winery", category: self.rawValue.localized)
        case .zoo:
            return Category(imageName: "zoo", category: self.rawValue.localized)
        }
	}
}
