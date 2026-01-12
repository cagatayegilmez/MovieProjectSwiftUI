//
//  ServiceLayer.swift
//  Mobillium Project
//
//  Created by Çağatay Eğilmez on 14.05.2022.
//

import Foundation
#if canImport(UIKit)
import UIKit
#endif
final class ServiceLayer {
    //MARK: -For sending rest requests
    func send<T: APIRequest>(request: T, canRetry: Bool = true, completion: @escaping (Result<T.Response, Error>) -> ()) {
        let session = URLSession(configuration: .default)
        let decoder = JSONDecoder()
        print(request.asURLRequest())
        print("⭕️⭕️⭕️⭕️⭕️⭕️⭕️⭕️⭕️⭕️⭕️")
        let dataTask = session.dataTask(with: request.asURLRequest()) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let _ = self else { return }
                guard let httpResponse = response as? HTTPURLResponse else {
                    completion(.failure(ServiceError.noHttpResponse))
                    return
                }
                print("//////////////////////////")
                print("--->\(httpResponse.statusCode)")
                switch httpResponse.statusCode {
                case 200..<300:
                    guard let data = data else {
                        completion(.failure(ServiceError.noData))
                        return
                    }
                    print("🔴🔴🔴🔴🔴🔴🔴🔴🔴🔴")
                    let dataString = String.init(data: data, encoding: .utf8)!
                    print(dataString)
                    if(dataString.isEmpty) {
                        completion(.success(EmptyResponse() as! T.Response))
                    } else {
                        do{
                            let baseResponse = try decoder.decode(T.Response.self, from: data)
                            completion(.success(baseResponse))
                        }catch {
                            print(response?.url?.absoluteString ?? "Last URL")
                            print("Decoding Error --> \(T.Response.self)")
                            print(error)
                            completion(.failure(ServiceError.decoding(error)))
                        }
                    }
                default:
                    guard let data = data,
                          let errorObject = try? decoder.decode(ServiceErrorObject.self, from: data).errorMessages.first else {
                        completion(.failure(ServiceError.fail(httpResponse.statusCode)))
                        return
                    }
                    print(errorObject.message)
                    print("........")
                    completion(.failure(ServiceError.customError(httpCode: httpResponse.statusCode, errorCode: errorObject.code)))
                    
                }
            }
        }
        dataTask.resume()
    }
}

enum ServiceError: Error {
    case invalidRefreshToken
    case noHttpResponse
    case noData
    case socialMediaReauth
    case fail(Int)
    case decoding(Error)
    case customError(httpCode: Int, errorCode: Int)
    
}

extension ServiceError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .customError(let message, let code):
            return NSLocalizedString(message.description, comment: "Error code:\(code)")
        default: return NSLocalizedString("Something went wrong.", comment: "")

        }
    }
}
struct ServiceErrorObject:Decodable{
    let errorMessages: [ErrorMessageObject]
    
    struct ErrorMessageObject: Decodable{
        let message: String
        let code: Int
    }
}

public struct APIBaseResponse<T: Decodable>: Decodable {
    public let data: T
}

