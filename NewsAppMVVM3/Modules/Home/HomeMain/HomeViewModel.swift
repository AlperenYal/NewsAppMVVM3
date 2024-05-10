//
//  HomeViewModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import UIKit
// MARK: - Home ViewModel
final class HomeViewModel {
    // MARK: - Identifiers
    public let homeCellId = "HomeCell"
    public let homeHeaderId = "HomeHeader"
    lazy var segueId : String = { return "toHomeDetail" }()
    
    // MARK: - Data Management
    var coredatanews: [FavoriteNewsCoreData] = []
    var articles: [Article] = []
    var articlesArray : [Article]?
    // MARK: - Selection Handling
    var selectedItem : HeaderSelections = .all {
        didSet {
            getDatas(query: selectedItem.name)
        }
    }
    // MARK: - Delegate
    weak var delegate: HomeControllerProtocol?
    
    // MARK: - Data Fetching
    private func getDatas(query: String) {
        
        let params: ArticleParameters = ArticleParameters(category: query)
        ArticleService.shared.getArticles(withEndpoint: .topHeadlines, params: params) { result, error  in
            if let error = error {
                print("DEBUG14: \(error)")
                self.delegate?.datasReceived(error: error)
            }else {
                print("DEBUG14: \(result)")
                self.delegate?.datasReceived(error: nil)
                self.articlesArray = result
                self.articles = self.articlesArray ?? [Article]()
            }
        }
    }
    // MARK: - Favorite Management
    func toggleFavorite(for article: Article) {
        guard let index = articlesArray?.firstIndex(where: { $0.url == article.url }) else {
            print("Article not found in array")
            return
        }
        let isFavorite = articlesArray![index].isFavorite
        articlesArray![index].isFavorite.toggle() // Toggle the isFavorite state
        if isFavorite {
            CoredataManager.shared.removeFavorite(article: articlesArray![index])
        } else {
            CoredataManager.shared.addFavorite(article: articlesArray![index])
        }
        // Notify the delegate to update UI
        DispatchQueue.main.async {
            self.delegate?.datasReceived(error: nil)
        }
        // Post notification for other parts of the app
        NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil, userInfo: ["article": articlesArray![index], "isFavorite": articlesArray![index].isFavorite])
    }
    // MARK: - Initial Fetch
    // Fetch data from API and CoreData
    func fetchData() {
        fetchArticlesFromAPI()
        fetchFavoriteStatusFromCoreData()
    }
    private func fetchArticlesFromAPI() {
        let params = ArticleParameters(category: selectedItem.name)
        ArticleService.shared.getArticles(withEndpoint: .topHeadlines, params: params) { [weak self] result, error in
            DispatchQueue.main.async {
                if let error = error {
                    // Proper use of error.localizedDescription because 'error' is of type 'Error'
                    self?.delegate?.datasReceived(error: error)
                    return
                }
                guard let articles = result else {
                    // Directly passing a custom error message as a string
                    self?.delegate?.datasReceived(error: "No articles found")
                    return
                }
                self?.articles = articles
                self?.mergeFavoriteStatus()
                self?.delegate?.datasReceived(error: nil)
            }
        }
    }
    private func fetchFavoriteStatusFromCoreData() {
        CoredataManager.shared.fetchFavoriteNews { [weak self] favorites, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let error = error {
                    // Correctly using localizedDescription with an Error object
                    self.delegate?.datasReceived(error: error.localizedDescription)
                    return
                }
                guard let favorites = favorites else {
                    self.delegate?.datasReceived(error: "Error fetching favorites")
                    return
                }
                self.coredatanews = favorites
                self.mergeFavoriteStatus()
            }
        }
    }
    // MARK: - Helper Methods
    private func mergeFavoriteStatus() {
        guard !coredatanews.isEmpty else { return }
        articlesArray = articles.map { article in
            var mutableArticle = article
            mutableArticle.isFavorite = coredatanews.contains { $0.url == article.url }
            return mutableArticle
        }
    }
}


