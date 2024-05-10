//
//  SplashViewModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation

// MARK: - Splash View Model
class SplashViewModel {
    // MARK: - Properties
    var articlesArray =  [Article]()
    
    weak var delegate : SplashViewControllerProtocol?
    // MARK: - Initializer
    init() {
        getDatas(query: "general")
    }
    
    let segueIdentifier = "showMainTabSegue"
    
    // MARK: - Data Fetching
    func getDatas(query: String) {
        let params: ArticleParameters = ArticleParameters(category: query)
        
        ArticleService.shared.getArticles(withEndpoint: .topHeadlines, params: params) { articles, error in
            if error != nil {
                print("DEBUG14",error)
                self.delegate?.datasReceived(error: error)
                return
            }
            guard let articles = articles else { return }
            self.articlesArray = articles
            dump(self.articlesArray)
            self.delegate?.datasReceived(error: nil)
        }
    }
    
    
}



