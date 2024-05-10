//
//  HomeCell2.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import UIKit
import SDWebImage
// MARK: - Home Cell Delegate Protocol
protocol HomeCellDelegate: AnyObject {
    func didTapFavoriteButton(article: Article, isFavorite: Bool)
}

// MARK: - Home Cell Class
class HomeCell: UICollectionViewCell {
    // MARK: - Properties
    var article : Article?
    {
        didSet {
            setUI()
        }
    }
    weak var delegate: HomeCellDelegate?
    // MARK: - Outlets
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var favoritesButton: UIButton!
    
    var coreDataArticle: FavoriteNewsCoreData?
    var indexPath: IndexPath?
    var newsArticle: Article?
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        favoritesButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        setImageView()
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.sd_cancelCurrentImageLoad()
    }
    
    //MARK: - Configurations
    private func setUI() {
        guard let article = self.article else { return }
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel
        
        sourceLabel.text = article.sourceLabel?.name
        
        if let url = article.imageView {
            imageView.sd_setImage(with: url) { (image, error, cache, urls) in
                if (error != nil) {
                    self.imageView.image = UIImage(named: "error")
                } else {
                    self.imageView.image = image
                }
            }
        } else {
            self.imageView.image = UIImage(named: "error")
        }
        
    }
    private func updateUI() {
        guard let article = article else { return }
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel ?? "No description available"
        sourceLabel.text = article.sourceLabel?.name ?? "Unknown source"
        
        if let urlString = article.imageView{
            imageView.sd_setImage(with: urlString, placeholderImage: UIImage(named: "placeholder"))
        } else {
            imageView.image = UIImage(named: "placeholder")  // Default image if URL is nil
        }
        updateFavoriteButtonImage()
    }
    
    func configure(with article: Article, isFavorite: Bool) {
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel ?? "No description"
        sourceLabel.text = article.sourceLabel?.name ?? "Unknown source"
        imageView.sd_setImage(with: article.imageView)
        if let imageUrl = article.imageView{
            imageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
        
        updateFavoriteButtonImage()
    }
    
    
    func updateFavoriteButtonImage() {
        guard let article = article else { return }
        let isFavorite = CoredataManager.shared.isArticleFavoriteByURL(article.url ?? "")
        let imageName = isFavorite ? "Vector 1" : "Vector"
        favoritesButton.setImage(UIImage(named: imageName), for: .normal)
    }
    @objc func favoriteButtonTapped(_ sender: UIButton) {
        guard let article = article else {
            debugPrint("Article is nil")
            return
        }
    }
    
    private func setImageView() {
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
    }
    
    @IBAction func favoriteButton (_ sender: UIButton) {
        debugPrint("Furkan tap1")
        if delegate == nil {
            debugPrint("Delegate is nil")
        }
        guard let article = article else {
            debugPrint("Article data is nil")
            return
        }
        debugPrint("Favorite button tapped for article: \(article.titleOneLabel)")
        delegate?.didTapFavoriteButton(article: article, isFavorite: article.isFavorite)
    }
    
}
