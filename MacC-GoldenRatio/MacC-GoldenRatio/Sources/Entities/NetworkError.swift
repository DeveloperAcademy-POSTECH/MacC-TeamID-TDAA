//
//  NetworkError.swift
//  MacC-GoldenRatio
//
//  Created by woo0 on 2022/10/29.
//

import Foundation

enum NetworkError: Error {
	case invalidURL
	case invalidJSON
	case networkError
	
	var message: String {
		switch self {
		case .invalidURL:
			return "데이터를 불러올 수 없습니다."
		case .invalidJSON:
			return "데이터를 파싱할 수 없습니다."
		case .networkError:
			return "네트워크 상태를 확인해주세요."
		}
	}
}
