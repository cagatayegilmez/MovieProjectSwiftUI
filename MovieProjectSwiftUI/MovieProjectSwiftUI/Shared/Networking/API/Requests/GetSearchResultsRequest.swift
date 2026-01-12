//
//  GetSearchResultsRequest.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 14.05.2022.
//

import Foundation
struct GetSearchResultsRequest: APIRequest {
    var headers: [String : String]? = nil
    
    var baseUrl: URL = Environment.rootURL

    typealias Response = SearchModel
    
    let method: HTTPMethodType = .get
    
    var path: String { "search/movie" }
    
    var queryParameters: [URLQueryItem] {
        return [
            URLQueryItem.init(name: "api_key", value: Environment.apiKey),
            URLQueryItem.init(name: "query", value: query),
            URLQueryItem.init(name: "page", value: "\(String(describing: page))")
        ]
    }
    
    var query: String!
    var page: Int!
}
