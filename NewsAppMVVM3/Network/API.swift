//
//  API.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//
import Foundation
import Moya
import UIKit

// MARK: - API Constants
enum API {
    static let apiKey = "ed2a202ff1634fd5a54b69fe5ca10e3b"
    static let baseUrlStr = "https://newsapi.org/v2/"
    
    enum Endpoint: String {
        case topHeadlines = "top-headlines"
        case everything = "everything"
    }
    static var baseURL: URL {
        guard let url = URL(string: baseUrlStr) else {
            fatalError("URL construction failed.")
        }
        return url
    }
}

// MARK: - TargetType Extension
extension TargetType {
    var baseURL: URL {
        return API.baseURL
    }
    
    
    var sampleData: Data {
        return Data()
    }
}
// MARK: - MoyaProvider Extension
extension MoyaProvider {
    func requestJSON(target: Target, retryCount: Int = 1, completion: @escaping(Result<Response, MoyaError>) -> Void) -> Cancellable {
        return self.request(target, callbackQueue: .main) { result in
            switch result {
            case .success(let response):
                switch response.statusCode {
                case 200, 204:
                    print("LIFEDEBUG: \(target.baseURL) ve \(target.path)")
                    completion(.success(response))
                case 401:
                    print("LIFEDEBUG: USER GOT 401 FAILED", target.path)
                    completion(.failure(.statusCode(response)))
                default:
                    completion(.failure(.statusCode(response)))
                }
            case .failure(let error):
                print("LIFEDEBUG: \(error.localizedDescription)")
                completion(.failure(error))
            }
        }
        
    }
}

// MARK: - JSON Response Formatter
func JSONResponseDataFormatter(_ data: Data) -> String {
    do {
        let dataAsJSON = try JSONSerialization.jsonObject(with: data)
        let prettyData =  try JSONSerialization.data(withJSONObject: dataAsJSON, options: .prettyPrinted)
        return String(data: prettyData, encoding: .utf8) ?? ""
    } catch {
        return String(data: data, encoding: .utf8) ?? ""
    }
}
