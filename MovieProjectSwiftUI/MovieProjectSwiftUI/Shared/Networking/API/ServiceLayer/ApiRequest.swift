//
//  ApiRequest.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 14.05.2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
let defaultHeaders: [String: String] = [
    "Content-Type": "application/json"
]

typealias ServiceResponse = Decodable

struct EmptyResponse: ServiceResponse { }

enum HTTPMethodType: String {
    case get = "GET"
    case post = "POST"
    case delete = "DELETE"
    case put = "PUT"
    case patch = "PATCH"
}

protocol APIRequest {
    var baseUrl: URL { get }
    var path: String { get }
    var httpBody: Data? { get }
    var queryParameters: [URLQueryItem] { get }
    var method: HTTPMethodType { get }
    var headers: [String:String]? { get }
    var formData: [String:String]? { get }
    associatedtype Response: ServiceResponse
}
extension APIRequest{
    var formData: [String:String]?{
        return nil
    }
    
    var httpBody: Data? {
        return nil
    }
}

extension APIRequest {
    func asURLRequest() -> URLRequest {
        var url = baseUrl.appendingPathComponent(path)
        if  !queryParameters.isEmpty {
            var components = URLComponents(
                url: url,
                resolvingAgainstBaseURL: false
            )
            components?.queryItems = queryParameters.removeNullValues()
            url = components?.url ?? url
        }
        var urlRequest = URLRequest(url: url)

        defaultHeaders.forEach{ header in
            urlRequest.addValue(header.value,forHTTPHeaderField: header.key)
        }
        
        if let headers = headers {
            headers.forEach {
                urlRequest.addValue($1, forHTTPHeaderField: $0)
            }
        }
                
        if let httpBody = httpBody {
            urlRequest.httpBody = httpBody
        }
        
        if let httpBody = formData{
            let formEncodedData = httpBody.map{ "\($0)=\($1)" }
                .joined(separator: "&")
                .data(using: String.Encoding.utf8)
            urlRequest.httpBody = formEncodedData
        }
        
        urlRequest.httpMethod = method.rawValue
        return urlRequest
    }
}

private extension Array where Element == URLQueryItem {
    func removeNullValues() -> [URLQueryItem] {
        return self.filter{$0.value != nil}
    }
}

