//
//  ArticleService.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation
import UIKit
import Moya

// MARK: - Network Endpoints

enum NetworkEndpoints : String {
    case everything, topHeadlines
    var url : String {
        switch self {
        case .everything: return "everything"
        case .topHeadlines: return "top-headlines"
        }
    }
}
// MARK: - Article API

enum ArticleAPI {
    case getArticles(withParameter: ArticleParameters, endpoint: NetworkEndpoints)
    case getSources(country: String)
    case searchArticles(query: String)
}

// MARK: - ArticleAPI TargetType Extension

extension ArticleAPI: TargetType {
    var headers: [String : String]? {
        return nil
    }
    
    var path: String {
        switch self {
        case .getArticles( _ ,let endpoint):
            // URL: "https://newsapi.org/v2/{endpoint.url}"
            return endpoint.url
        case .getSources:
            // URL: "https://newsapi.org/v2/top-headlines/sources"
            return NetworkEndpoints.topHeadlines.url + "/sources"
        case .searchArticles:
            // URL: "https://newsapi.org/v2/everything"
            return NetworkEndpoints.everything.url
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getArticles, .getSources, .searchArticles:
            return .get

        }
    }
    
    var task: Task {
        switch self {
        case .getArticles(let parameters, _):
            var params: [String: Any] = ["apiKey": API.apiKey]
            if let source = parameters.source {
                params["sources"] = source
            } else {
                params["country"] = "us"
                /*
                if let country = parameters.country {
                    params["country"] = country
                }*/
                if let category = parameters.category {
                    params["category"] = category
                }
            }
            print("DEBUG13:",params)
            return .requestParameters(parameters: params, encoding: URLEncoding.default)
            
        case .getSources(let country):
            return .requestParameters(parameters: ["country": "us", "apiKey": API.apiKey], encoding: URLEncoding.default)
            
        case .searchArticles(let query):
            return .requestParameters(parameters: ["q": query, "apiKey": API.apiKey], encoding: URLEncoding.default)
        }
    }
}
