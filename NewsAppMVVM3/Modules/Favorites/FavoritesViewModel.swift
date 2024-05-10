//
//  FavoritesViewModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 29.04.2024.
//

import UIKit

// MARK: - FavoritesViewModel
final class FavoritesViewModel {
    // MARK: - Properties
    public let favoritesCellId = "HomeCell"
    lazy var segueId: String = { return "toHomeDetail" }()
    var coredatanews: [FavoriteNewsCoreData] = []
    var selectedItem: HeaderSelections = .all
    var articles: [Article] = []
    weak var delegate: FavoritesControllerProtocol?
    var articlesArray: [Article]? {
        didSet {
            debugPrint("Favorites updated: \(self.articlesArray?.map({$0.titleOneLabel}) ?? [])")
        }
    }
    // MARK: - Data Fetching
    func getDatas(query: String) {
        CoredataManager.shared.fetchFavoriteNews { [weak self] news, error in
            guard let self = self, let news = news, error == nil else {
                self?.delegate?.datasReceived(error: error?.localizedDescription)
                return
            }
            self.articlesArray = news.map { coreDataArticle in
                Article(
                    titleOneLabel: coreDataArticle.titleOneLabel,
                    url: coreDataArticle.url,
                    imageView: URL(string: coreDataArticle.imageView ?? ""),
                    titleTwoLabel: coreDataArticle.titleTwoLabel,
                    sourceLabel: Source(id: "", name: coreDataArticle.sourceLabel),
                    isFavorite: true
                )
            }
            self.delegate?.datasReceived(error: nil)
        }
    }
    
}
