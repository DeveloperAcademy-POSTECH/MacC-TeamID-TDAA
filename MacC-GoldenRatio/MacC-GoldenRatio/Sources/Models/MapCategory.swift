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
	case def = ""
}
