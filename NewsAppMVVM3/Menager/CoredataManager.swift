//
//  CoredataManager.swift
//
//  NewsAppMVVM3
//
//  Created by Apple on 6.05.2024.
//
//
import Foundation
import CoreData
import UIKit

// MARK: - Enums
enum NetworkEndpoints2 : String {
    case everything, topHeadlines2
    var url : String {
        switch self {
        case .everything: return "everything"
        case .topHeadlines2: return "top-headlines2"
        }
    }
}
// MARK: - Core Data Manager

public class CoredataManager: NSManagedObject {
    
    // MARK: - Managed Object Properties
    
    @NSManaged public var titleOneLabel: String
    @NSManaged public var titleTwoLabel: String
    @NSManaged public var url: String
    @NSManaged public var imageView: String?
    @NSManaged public var sourceLabel: String
    
    // MARK: - Properties
    
    var articles: [Article] = []
    var coredatanews: [FavoriteNewsCoreData] = []
    let apiService = ArticleService.shared
    var managedContext: NSManagedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var searchResults: [Article] = []
    static let shared = CoredataManager()
    var isLoading = false
    var currentPage = 1
    var pageSize = 10
    var hasMoreArticles = true
    
    func isArticleFavorite(_ article: Article) -> Bool {
        let isFav = coredatanews.contains(where: { $0.url == article.url })
        debugPrint("Checking if article is favorite: \(isFav)")
        return isFav
    }
    
    // MARK: - Article Fetching
    
    func fetchTopHeadlines(category: String, completion: @escaping (Bool, Error?) -> Void) {
        guard !isLoading && hasMoreArticles else { return }
        isLoading = true
        
        ArticleService.shared.fetchTopHeadlines(forCategory: category, page: currentPage, pageSize: pageSize) { [weak self] (articles, error) in
            DispatchQueue.main.async { [weak self] in
                self?.isLoading = false
                if let error = error {
                    completion(false, error)
                    return
                }
                
                guard let articles = articles else {
                    completion(false, nil)
                    return
                }
                
                if articles.count < self!.pageSize {
                    self?.hasMoreArticles = false
                }
                
                self?.articles.append(contentsOf: articles)
                self?.currentPage += 1
                completion(true, nil)
            }
        }
    }
    
    
    
    func isArticleFavoriteByURL(_ url: String) -> Bool { // favori kontrolü
        return coredatanews.contains(where: { $0.url == url })
    }
  
    // MARK: - Favorites Management
   
    func addFavorite(article: Article) {
        let fetchRequest: NSFetchRequest<FavoriteNewsCoreData> = FavoriteNewsCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url = %@", article.url ?? "")

        do {
            let results = try managedContext.fetch(fetchRequest)
            if results.isEmpty { // Check if no existing entry for this URL
                let newFavorite = FavoriteNewsCoreData(context: managedContext)
                newFavorite.titleOneLabel = article.titleOneLabel
                newFavorite.url = article.url
                newFavorite.imageView = article.imageView?.absoluteString

                try managedContext.save()
                NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil)
                debugPrint("Article added to favorites")
            } else {
                debugPrint("Article already exists in favorites")
            }
        } catch let error as NSError {
            print("Could not save or fetch. \(error), \(error.userInfo)")
        }
    }


        func removeFavorite(article: Article) {
            let fetchRequest: NSFetchRequest<FavoriteNewsCoreData> = FavoriteNewsCoreData.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "url = %@", article.url ?? "")

            do {
                let results = try managedContext.fetch(fetchRequest)
                for object in results {
                    managedContext.delete(object)
                }

                try managedContext.save()
                NotificationCenter.default.post(name: .favoriteStatusChanged, object: nil)
                debugPrint("Article removed from favorites")
            } catch let error as NSError {
                print("Could not delete. \(error), \(error.userInfo)")
            }
        }


   
    func toggleFavorite(article: Article) {
        let fetchRequest: NSFetchRequest<FavoriteNewsCoreData> = FavoriteNewsCoreData.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "url = %@", article.url ?? "")

        do {
            let results = try managedContext.fetch(fetchRequest)
            debugPrint("Toggle Favorite - Fetched results count: \(results.count)")

            if results.isEmpty {
                debugPrint("Article not in favorites, adding...")
                addFavorite(article: article)
            } else {
                debugPrint("Article found in favorites, removing...")
                removeFavorite(article: article)
            }
        } catch let error as NSError {
            print("Could not toggle favorite: \(error), \(error.userInfo)")
        }
    }


    // MARK: - Core Data Retrieval
    
    func fetchFavoriteNews(completion: @escaping ([FavoriteNewsCoreData]?, Error?) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion(nil, NSError(domain: "AppDelegateError", code: -1, userInfo: nil))
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest<FavoriteNewsCoreData> = FavoriteNewsCoreData.fetchRequest()
        
        do {
            let results = try managedContext.fetch(fetchRequest)
            self.coredatanews = results
            coredatanews.forEach { coreData in
                debugPrint(coreData.titleOneLabel, "core_data_count")
            }
            debugPrint(coredatanews.count, "core_data_count")
            completion(results, nil)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completion(nil, error)
        }
    }
    func updateFavoriteStatus(for title: String, isFavorite: Bool) {
        if let index = articles.firstIndex(where: { $0.titleOneLabel == title }) {
            articles[index].isFavorite = isFavorite
        }
    }
    
    func findCoreDataArticle(article: Article) -> FavoriteNewsCoreData? {
        return coredatanews.first { $0.titleOneLabel == article.titleOneLabel }
    }
}
func mapToCoredataManager(from newsArticle: Article) -> CoredataManager {
    let favoriteNews = CoredataManager()
    favoriteNews.titleOneLabel = newsArticle.titleOneLabel ?? ""
    favoriteNews.titleTwoLabel = newsArticle.titleTwoLabel ?? ""
    favoriteNews.sourceLabel = newsArticle.sourceLabel?.name ?? ""
    favoriteNews.url = newsArticle.url ?? ""
    favoriteNews.imageView = (newsArticle.imageView ?? URL(string: ""))?.absoluteString
    return favoriteNews
}

// MARK: - Extensions

extension CoredataManager {
    
    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteNewsCoreData> {
        return NSFetchRequest<FavoriteNewsCoreData>(entityName: "FavoriteNewsCoreData")
        
    }
    
}

extension CoredataManager: Identifiable {
    
}
