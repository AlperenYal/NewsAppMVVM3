//
//  SearchViewModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation
// MARK: - Search View Model
class SearchViewModel {
    // MARK: - Properties
    let cellIdentifier = "SearchCell"
    var articlesArray : [Article]?
    var coredatanews: [FavoriteNewsCoreData] = []
    var sourcesArray: [SourceDetails]? {
        didSet {
            // Notify the delegate to reload data whenever sourcesArray is updated
            self.delegate?.didReceiveData(error: nil)
        }
    }
    lazy var segueId: String = { return "toSearchDetail" }()
    var sourceId: String?
    weak var delegate: SearchControllerProtocol?
    let headerId = "SearchHeader"
    // MARK: - Initializer
    init() {
        
    }
    // MARK: - Favorite Status
    func isArticleFavoriteByURL(_ url: String) -> Bool { // favori kontrolü
        return coredatanews.contains(where: { $0.url == url })
    }
    // MARK: - Search Handling
    func searchNews(query: String, completion: @escaping ([Article]) -> Void) {
        CoredataManager.shared.apiService.searchNews(query: query) { articles, error in
            if let error = error {
                print("Error occurred: \(error)")
                return
            }
            if let articles = articles {
                self.articlesArray = articles  // Ensure this assignment is happening correctly
                DispatchQueue.main.async {
                    self.delegate?.didReceiveData(error: nil)
                }
                completion(articles)
            } else {
                print("No articles found")
            }
        }
    }
    // MARK: - Favorite Management
    func toggleFavorite(for article: Article) {
        print("Attempting to toggle favorite for article with URL: \(article.url ?? "no URL")")
        print("Current articles in array: \(articlesArray?.map { $0.url } ?? [])")
        
        guard let index = articlesArray?.firstIndex(where: { $0.url == article.url }) else {
            print("Article not found in array")
            DispatchQueue.main.async {
                self.delegate?.didReceiveData(error: "Article not found in the list.")
            }
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
            self.delegate?.didReceiveData(error: nil)
        }
        // Post notification for other parts of the app
        NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil, userInfo: ["article": articlesArray![index], "isFavorite": articlesArray![index].isFavorite])
    }
    
}
