//
//  SearchController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//
import UIKit
import CoreData
// MARK: - Search Controller Protocol
protocol SearchControllerProtocol: AnyObject {
    func didReceiveData(error: String?)
}

// MARK: - Main View Controller
class SearchController: UIViewController, SearchCellDelegate {
    // MARK: - Properties
    let viewModel = SearchViewModel()
    var searchResults: [Article] = []
    var favoriteNews: [FavoriteNewsCoreData] = []
    var coredatanews: [FavoriteNewsCoreData] = []
    weak var delegate: SearchHeader?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        // MARK: - Properties
        super.viewDidLoad()
        tableView.estimatedRowHeight = 100  // Set a reasonable estimate
        tableView.rowHeight = UITableView.automaticDimension
        registerNibs()
        registerObservers()
        configureUI()
        self.viewModel.delegate = self
        CoredataManager.shared.fetchFavoriteNews { [weak self] (favorites, error) in
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.delegate = self
            tableView.dataSource = self
            registerNibs()
        }
    }
    // MARK: - Data Fetching
    func fetchFavoriteData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteNewsCoreData")
        
        do {
            if let results = try managedContext.fetch(fetchRequest) as? [FavoriteNewsCoreData] {
                self.viewModel.coredatanews = results
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    func searchArticles(query: String) {
        debugPrint(query)
        viewModel.searchNews(query: query) { [weak self] articles in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.searchResults = articles.map { article -> Article in
                    var modArticle = article
                    modArticle.isFavorite = self.viewModel.isArticleFavoriteByURL(article.url ?? "") ?? false
                    return modArticle
                }
                self.tableView.reloadData()
            }
        }
    }
    // MARK: - Observer Setup
    private func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavoriteNews3), name: .favoriteStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteStatusChanged3(notification:)), name: .favoriteStatusChanged, object: nil)
    }
    
    //MARK: - Actions
    func didTapFavoriteButton(article: Article, isFavorite: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewModel.toggleFavorite(for: article)
            self.tableView.reloadData()
        }
    }
    
    @objc func refreshFavoriteNews3(notification: Notification) {
        CoredataManager.shared.fetchFavoriteNews { [weak self] (favorites, error) in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if let favorites = favorites {
                    self.favoriteNews = favorites
                    self.tableView.reloadData()
                } else if let error = error {
                    print("Error updating favorites: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func handleFavoriteStatusChanged3(notification: Notification) {
        if let userInfo = notification.userInfo,
           let article = userInfo["article"] as? Article,
           let isFavorite = userInfo["isFavorite"] as? Bool {
            // Find the article in your array and update its favorite status
            if let index = searchResults.firstIndex(where: { $0.url == article.url }) {
                searchResults[index].isFavorite = isFavorite
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    // MARK: - UI Setup
    private func configureUI() {
        tableView.register(UINib(nibName: viewModel.cellIdentifier, bundle: nil), forCellReuseIdentifier: viewModel.cellIdentifier)
        tableView.register(UINib(nibName: viewModel.headerId, bundle: nil), forHeaderFooterViewReuseIdentifier: viewModel.headerId)
    }
    // MARK: - UI Setup
    private func registerNibs() {
        //MARK: - Cell nib
        let tableViewCellNib = UINib(nibName: viewModel.cellIdentifier, bundle: nil)
        tableView.register(tableViewCellNib, forCellReuseIdentifier: viewModel.cellIdentifier)
        
        //MARK: - Header nib
        let tableViewHeaderNib = UINib(nibName: viewModel.headerId, bundle: nil)
        tableView.register(tableViewHeaderNib, forHeaderFooterViewReuseIdentifier: viewModel.headerId)
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: viewModel.headerId) as? SearchHeader else { fatalError("Could not load header!!!")}
            header.viewModel.delegate = self
            return header
        }else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 100
    }
    
}
// MARK: - TableView Delegate & DataSource
extension SearchController: UITableViewDataSource, UITableViewDelegate  {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.articlesArray?.count ?? 0
    }
    
    // Set the height for each row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell", for: indexPath) as! SearchCell
        let article = searchResults[indexPath.row]
        cell.delegate = self
        cell.article = article
        
        // Configure cell labels to support dynamic text wrapping, etc.
        cell.titleOneLabel.numberOfLines = 0
        cell.titleTwoLabel.numberOfLines = 0
        
        if let url = article.imageView {
            cell.searchImageView.sd_setImage(with: url)
        } else {
            cell.searchImageView.image = UIImage(named: "defaultPlaceholder")
        }
        
        cell.configure(with: article, isFavorite: CoredataManager.shared.isArticleFavorite(article))
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = searchResults[indexPath.row]
        if let urlString = article.url {
            let detailVC = HomeDetailsController(urlString: urlString)
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
        }
    }
    func isArticleFavorite(_ article: Article) -> Bool {
        return coredatanews.contains(where: { $0.title == article.titleOneLabel })
    }
    
}
// MARK: - Search Header Protocol Implementation
extension SearchController: SearchHeaderSearchBarProtocol {
    func searchHeaderDidTapSend(searchText: String) {
        searchArticles(query: searchText)
    }
}
// MARK: - Search Controller Protocol Implementation
extension SearchController: SearchControllerProtocol {
    func didReceiveData(error: String?) {
        
        if let error = error {
            debugPrint("Error Received:", error)
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.tableView.reloadData()
            }
        }
    }
}
