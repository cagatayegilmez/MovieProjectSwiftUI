//
//  GetMovieDetailRequest.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 14.05.2022.
//

import Foundation
struct GetMovieDetailRequest: APIRequest {
    var headers: [String : String]? = nil
    
    var baseUrl: URL = Environment.rootURL

    typealias Response = MovieDetailModel
    
    let method: HTTPMethodType = .get
    
    var path: String { "movie/\(String(describing: movieId ?? 0))" }
    
    var queryParameters: [URLQueryItem] {
        return [URLQueryItem.init(name: "api_key", value: Environment.apiKey)]
    }
    
    var movieId: Int!
}
