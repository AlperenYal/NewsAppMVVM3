//
//  HomeController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//
import UIKit
import CoreData
import Foundation
import SDWebImage


// MARK: - Home Controller Protocol
protocol HomeControllerProtocol: AnyObject {
    func datasReceived(error: String?)
}
// MARK: - Home Controller
class HomeController: UICollectionViewController, HomeCellDelegate {
    
    
    //MARK: - Properties
    
    let viewModel = HomeViewModel()
    var favoriteNews: [FavoriteNewsCoreData] = []
    var coredatanews: [FavoriteNewsCoreData] = []
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.delegate = self
        viewModel.fetchData()  // Fetch data from both API and CoreData
        self.viewModel.delegate = self
        
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavoriteNews2), name: .favoriteStatusChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleFavoriteStatusChanged(notification:)), name: .favoriteStatusChanged, object: nil)
        
        CoredataManager.shared.fetchFavoriteNews { [weak self] (favorites, error) in
            DispatchQueue.main.async { [weak self] in
                
                self?.collectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchFavoriteData()
        
        let refreshControl = UIRefreshControl()
        collectionView.refreshControl = refreshControl
        collectionView.reloadData()
    }
    
    
    //MARK: - ConfigureUI
    func configureUI() {
        self.collectionView.register(UINib(nibName: viewModel.homeCellId, bundle: nil), forCellWithReuseIdentifier: viewModel.homeCellId)
        self.collectionView.register(UINib(nibName: viewModel.homeHeaderId, bundle: nil), forSupplementaryViewOfKind:UICollectionView.elementKindSectionHeader, withReuseIdentifier: viewModel.homeHeaderId)
        
    }
    
    //MARK: - Actions
    func didTapFavoriteButton(article: Article, isFavorite: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.viewModel.toggleFavorite(for: article)
            self.collectionView.reloadData()
        }
    }
    // MARK: - Data Handling
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
    @objc func refreshFavoriteNews2(notification: Notification) {
        CoredataManager.shared.fetchFavoriteNews { [weak self] (favorites, error) in
            guard let self = self else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                if let favorites = favorites {
                    self.favoriteNews = favorites
                    self.collectionView.reloadData()
                } else if let error = error {
                    print("Error updating favorites: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc func handleFavoriteStatusChanged(notification: Notification) {
        if let userInfo = notification.userInfo,
           let updatedArticle = userInfo["article"] as? Article,
           let isFavorite = userInfo["isFavorite"] as? Bool {
            
            if let index = viewModel.articlesArray?.firstIndex(where: { $0.url == updatedArticle.url }) {
                viewModel.articlesArray?[index].isFavorite = isFavorite
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
            }
        }
    }
}

// MARK: UICollectionViewDataSource
extension HomeController {
    
    func isArticleFavorite(_ article: Article) -> Bool {
        return favoriteNews.contains(where: { $0.titleOneLabel == article.titleOneLabel })
    }
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.viewModel.articlesArray?.count ?? 0
    }
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.homeCellId, for: indexPath) as? HomeCell else {
            fatalError("HomeCell not found")
        }
        if let article = viewModel.articlesArray?[indexPath.row] {
            cell.article = article
            cell.updateFavoriteButtonImage()
            cell.delegate = self
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        switch kind {
        case UICollectionView.elementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: viewModel.homeHeaderId, for: indexPath) as! HomeHeader
            headerView.viewModel.delegate = self
            return headerView
        default:
            assert(false, "Unexpected element kind")
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width, height: 55)
    }
}

//MARK: - UICollectionDelegateFlowLayout

extension HomeController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let padding: CGFloat = 20
        let collectionViewSize = collectionView.frame.size.width - padding
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            return CGSize(width: collectionViewSize/2, height: collectionViewSize/4)
        } else {
            return CGSize(width: collectionViewSize, height: collectionViewSize/2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    }
    
}
//MARK: - HomeControllerDelegate
extension HomeController {
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let article = viewModel.articlesArray?[indexPath.row] else { return }
        performSegue(withIdentifier: viewModel.segueId, sender: article)
    }
}

//MARK: - HomeControllerProtocolDelegate
extension HomeController: HomeControllerProtocol {
    func datasReceived(error: String?) {
        if let error = error {
            print("Error received: \(error)")
        } else {
            DispatchQueue.main.async { [weak self] in
                self?.collectionView.reloadData()
            }
        }
    }
}
//MARK: - Segues
extension HomeController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == viewModel.segueId, let detailsVC = segue.destination as? HomeDetailsController, let article = sender as? Article {
            detailsVC.viewModel.article = article
            detailsVC.urlString = article.url // Assuming `urlString` is the property you use to load content
        }
    }
}

//MARK: - HomeHeaderProtocol
extension HomeController : HomeHeaderProtocol {
    func didSelectFilter(selectedIndex: Int) {
        debugPrint("Filter selected at index: \(selectedIndex)")
        guard let selection = HeaderSelections(rawValue: selectedIndex) else {
            fatalError("Invalid selection index")
        }
        viewModel.selectedItem = selection  // Update the selected item in the viewModel
        viewModel.fetchData()  // Fetch new data based on the selected filter
    }
}
