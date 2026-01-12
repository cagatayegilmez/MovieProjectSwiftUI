//
//  GetSimilarMoviesRequest.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 14.05.2022.
//

import Foundation
struct GetSimilarMoviesRequest: APIRequest {
    var headers: [String : String]? = nil
    
    var baseUrl: URL = Environment.rootURL

    typealias Response = SimilarMoviesModel
    
    let method: HTTPMethodType = .get
    
    var path: String { "movie/\(String(describing: movieId))/similar" }
    
    var queryParameters: [URLQueryItem] {
        return [
            URLQueryItem.init(name: "api_key", value: Environment.apiKey),
            URLQueryItem.init(name: "page", value: "\(String(describing: page))")
        ]
    }
    
    var movieId: Int!
    var page: Int!
}
