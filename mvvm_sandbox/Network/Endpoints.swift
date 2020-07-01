//
//  EndPoints.swift
//  AtomicApp
//
//  Created by Omar Gomez on 5/25/18.
//  Copyright © 2018 Omar Gómez. All rights reserved.
//

import Foundation

enum PPOCEndPoint {
    
    static let baseURL = "https://loc.gov/pictures"

    //PPOC
    case home
    case search(query: String? = nil, style: String = "list", collectionCode: String? = nil, startPage: Int = 1)
    case collection(code: String)

    private func buildURL(_ path: String, _ params: [String: String]) -> URL? {
        guard var components = URLComponents(string: PPOCEndPoint.baseURL + path) else {
            return nil
        }
        components.queryItems = params.map {
            URLQueryItem(name: $0.key, value: $0.value)
        }
        components.percentEncodedQuery = components.percentEncodedQuery?.replacingOccurrences(of: "+", with: "%2B")
        return components.url
    }
    
    var url: URL {
        switch self {
        case .home:
            return URL(string: String(format: "%@/?fo=json", PPOCEndPoint.baseURL))!
        case .search(let query, let style, let collectionCode, let startPage):
            var params: [String: String] = [
                "fo": "json",
                "st": style,
                "sp": String(startPage),
            ]
            
            if let co = collectionCode {
                params["co"] = co
            }
            
            if let q = query {
                params["q"] = q
            }
            
            return buildURL("/search/", params)!
        case .collection(let code):
            return URL(string: String(format: "%@/pictures/collection/%@/?fo=json", PPOCEndPoint.baseURL, code))!
        }
    }

}

