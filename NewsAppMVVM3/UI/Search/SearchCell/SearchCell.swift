//
//  SearchCell.swift
//  NewsAppMVVM3
//
//  Created by Apple on 9.05.2024.
//

import UIKit
import SDWebImage
// MARK: - Search Cell Delegate Protocol
protocol SearchCellDelegate: AnyObject {
    func didTapFavoriteButton(article: Article, isFavorite: Bool)
}
// MARK: - Search Cell Class
class SearchCell: UITableViewCell {
    
    // MARK: - Outlets
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleOneLabel: UILabel!
    @IBOutlet weak var titleTwoLabel: UILabel!
    @IBOutlet weak var favoritesButton: UIButton!
    @IBOutlet weak var searchImageView: UIImageView!
    // MARK: - Properties
    weak var delegate: SearchCellDelegate?
    var coreDataArticle: CoredataManager?
    var indexPath: IndexPath?
    var newsArticle: Article?
    var article : Article?
    {
        didSet {
            setUI()
        }
    }
    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        favoritesButton.addTarget(self, action: #selector(favoriteButtonTapped(_:)), for: .touchUpInside)
        setImageView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        searchImageView.sd_cancelCurrentImageLoad()
    }
    // MARK: - UI Updates
    private func updateUI() {
        guard let article = article else { return }
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel ?? "No description available"
        sourceLabel.text = article.sourceLabel?.name ?? "Unknown source"
        
        if let urlString = article.imageView{
            searchImageView.sd_setImage(with: urlString, placeholderImage: UIImage(named: "placeholder"))
        } else {
            searchImageView.image = UIImage(named: "placeholder")  // Default image if URL is nil
        }
        updateFavoriteButtonImage()
    }
    
    //MARK: - Configurations
    private func setUI() {
        guard let article = self.article else { return }
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel
        sourceLabel.text = article.sourceLabel?.name
        
        if let url = article.imageView {
            searchImageView.sd_setImage(with: url) { (image, error, cache, urls) in
                if (error != nil) {
                    self.searchImageView.image = UIImage(named: "error")
                } else {
                    self.searchImageView.image = image
                }
            }
        } else {
            self.searchImageView.image = UIImage(named: "error")
        }
        
    }
    func configure(with article: Article, isFavorite: Bool) {
        titleOneLabel.text = article.titleOneLabel
        titleTwoLabel.text = article.titleTwoLabel ?? "No description"
        sourceLabel.text = article.sourceLabel?.name ?? "Unknown source"
        searchImageView.sd_setImage(with: article.imageView)
        if let imageUrl = article.imageView{
            searchImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "placeholder"))
        } else {
            searchImageView.image = UIImage(named: "placeholder")
        }
        
        updateFavoriteButtonImage()
    }
    
    func updateFavoriteButtonImage() {
        guard let article = article else { return }
        let isFavorite = CoredataManager.shared.isArticleFavoriteByURL(article.url ?? "")
        let imageName = isFavorite ? "Vector 1" : "Vector"
        favoritesButton.setImage(UIImage(named: imageName), for: .normal)
    }
    private func setImageView() {
    }
    // MARK: - Actions
    @IBAction func favoriteButtonTapped(_ sender: UIButton) {
        guard let article = self.article else {
            debugPrint("Article is nil")
            return
        }
    }
    
    
    @IBAction func favoriteButton (_ sender: UIButton) {
        debugPrint("Furkan tap1")
        if delegate == nil {
            debugPrint("Delegate is nil")
        }
        guard let article = self.article else {
            debugPrint("Article data is nil")
            return
        }
        debugPrint("Favorite button tapped for article: \(article.titleOneLabel)")
        delegate?.didTapFavoriteButton(article: article, isFavorite: article.isFavorite)
    }
    
}


