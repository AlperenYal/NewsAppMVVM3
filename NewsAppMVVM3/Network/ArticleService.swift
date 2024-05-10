//
//  ArticleService.swift
//  NewsAppMVVM3
//
//  Created by Apple on 03.05.2024.
//



import Foundation
import Moya

// MARK: - Models

struct NewsAPIResponseAPI: Decodable {
    let articles: [Article]
}

// MARK: - Article Service

final class ArticleService {
    
    // MARK: - Properties
    private let provider = MoyaProvider<ArticleAPI>()
    static public let shared = ArticleService()
    
    private init() {}
    
    // MARK: - Public Methods
    func getArticles(withEndpoint endPoint: NetworkEndpoints, params: ArticleParameters, completion: @escaping([Article]?, String?) -> Void ) {
        provider.requestJSON(target: .getArticles(withParameter: params, endpoint: endPoint)) { result in
            
            switch result {
                
            case .success(let response):
                do {
                    let results = try response.map(News.self)
                    completion(results.articles,nil)
                } catch {
                    debugPrint("error_here", error.localizedDescription)
                    completion(nil,error.localizedDescription)
                }
                
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func getSources(country: String , completion: @escaping([SourceDetails]?, String?) -> Void ) {
        provider.requestJSON(target: .getSources(country: country)) { result in
            switch result {
            case .success(let response):
                let results = try? response.map(CompanySources.self)
                completion(results?.sources,nil)
            case .failure(let error):
                completion(nil, error.localizedDescription)
            }
        }
    }
    
    func searchArticles(query: String, completion: @escaping([Article]?, String?) -> Void) {
        provider.requestJSON(target: .searchArticles(query: query)) { result in
            switch result {
                
            case .success(let response):
                let results = try? response.map(News.self)
                completion(results?.articles,nil)
            case .failure(let error):
                completion(nil,error.localizedDescription)
            }
        }
    }
    func fetchTopHeadlines(forCategory category: String, page: Int, pageSize: Int, completion: @escaping ([Article]?, Error?) -> Void) {
        debugPrint("test1_1_1")
        let urlString = "\(API.baseURL)\(NetworkEndpoints.topHeadlines.rawValue)?country=us&category=\(category)&apiKey=\(API.apiKey)&page=\(page)&pageSize=\(pageSize)"
        
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil) as Error)
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(NewsAPIResponseAPI.self, from: data)
                completion(response.articles, nil)
                
            } catch {
                debugPrint("erro_heere", error)
                completion(nil, error)
            }
        }.resume()
    }
    func searchNews(query: String, completion: @escaping ([Article]?, Error?) -> Void) {
        let urlString = "\(API.baseUrlStr)\(API.Endpoint.everything.rawValue)?q=\(query)&apiKey=\(API.apiKey)"
        
       
        guard let url = URL(string: urlString) else {
            completion(nil, NSError(domain: "InvalidURL", code: 0, userInfo: nil))
            return
        }
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let data = data else {
                completion(nil, NSError(domain: "NoData", code: 0, userInfo: nil))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let response = try decoder.decode(NewsAPIResponseAPI.self, from: data)
                completion(response.articles, nil)
                
            } catch {
                completion(nil, error)
            }
        }.resume()
    }
    
}
