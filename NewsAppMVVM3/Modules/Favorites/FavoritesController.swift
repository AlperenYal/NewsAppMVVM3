//
//  FavoritesController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 29.04.2024.
//

import UIKit
import CoreData
import SDWebImage

// MARK: - Notification.Name Extension
extension Notification.Name {
    static let favoriteStatusChanged = Notification.Name("favoriteStatusChanged")
}

// MARK: - FavoritesControllerProtocol
protocol FavoritesControllerProtocol: AnyObject {
    func datasReceived(error: String?)
}

// MARK: - FavoritesController
class FavoritesController: UICollectionViewController, HomeCellDelegate , SearchCellDelegate {
    
    // Other properties...
    private var noFavoritesLabel: UILabel!
    
    // MARK: - Properties
    let favoritesViewModel = FavoritesViewModel()
    // Correct usage
    let manager = CoredataManager.shared
    
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        NotificationCenter.default.addObserver(self, selector: #selector(refreshFavoriteNews), name: .favoriteStatusChanged, object: nil)
        
        favoritesViewModel.delegate = self
        favoritesViewModel.getDatas(query: favoritesViewModel.selectedItem.name)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.collectionView.reloadData()
    }
    // MARK: - Configure UI
    func configureUI() {
        collectionView.register(UINib(nibName: "HomeCell", bundle: nil), forCellWithReuseIdentifier: favoritesViewModel.favoritesCellId)
        
        // Configure noFavoritesLabel
        noFavoritesLabel = UILabel(frame: .zero)
        noFavoritesLabel.text = "Favori haber yok."
        noFavoritesLabel.textAlignment = .center
        noFavoritesLabel.textColor = .gray
        noFavoritesLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        noFavoritesLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noFavoritesLabel)
        
        NSLayoutConstraint.activate([
            noFavoritesLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            noFavoritesLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    // MARK: - Actions
    func didTapFavoriteButton(article: Article, isFavorite: Bool) {
        DispatchQueue.main.async {
            CoredataManager.shared.removeFavorite(article: article)
            self.collectionView.reloadData()
        }
    }
    
    @objc func refreshFavoriteNews(notification: Notification) {
        // You can access the userInfo like this:
        if let userInfo = notification.userInfo,
           let article = userInfo["article"] as? Article,
           let isFavorite = userInfo["isFavorite"] as? Bool {
            print("Article \(article.titleOneLabel) favorite status is now \(isFavorite)")
        }
        favoritesViewModel.getDatas(query: favoritesViewModel.selectedItem.name)
    }
    
    // MARK: - UICollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return favoritesViewModel.articlesArray?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: favoritesViewModel.favoritesCellId, for: indexPath) as? HomeCell else {
            fatalError("HomeCell not found")
        }
        let article = favoritesViewModel.articlesArray?[indexPath.row]
        cell.article = article
        cell.delegate = self
        cell.updateFavoriteButtonImage()
        return cell
    }
    // MARK: - UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: favoritesViewModel.segueId, sender: favoritesViewModel.articlesArray?[indexPath.row])
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == favoritesViewModel.segueId {
            if let detailsVC = segue.destination as? HomeDetailsController, let article = sender as? Article {
                detailsVC.viewModel.article = article
            }
        }
    }
}

// MARK: - FavoritesControllerProtocol Implementation
extension FavoritesController: FavoritesControllerProtocol {
    func datasReceived(error: String?) {
        if let error = error {
            debugPrint("Error Received: \(error)")
        } else {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.collectionView.reloadData()
                // Update label visibility based on favorites count
                self.noFavoritesLabel.isHidden = !(self.favoritesViewModel.articlesArray?.isEmpty ?? true)
            }
        }
    }
}

