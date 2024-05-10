//
//  Details2Cell.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//


import UIKit
import SDWebImage

class DetailsCell: UITableViewCell {
    //MARK: - Properties
    
    var article: Article? {
        didSet {
            configureArticle()
        }
    }
    //MARK: - Labels
    @IBOutlet weak var imageViewLabel: UIImageView!
    @IBOutlet weak var sourceLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        setImageView()
        
    }
    //MARK: - Functions
    func configureArticle(){
        guard let article = self.article else {
            print("DEBUG: Could not set article")
            return
        }
        print("Configured Article")
        sourceLabel.text = article.sourceLabel?.name
        titleLabel.text = article.titleOneLabel
        descriptionLabel.text = article.titleTwoLabel
        
        if let url = article.imageView {
            imageViewLabel.sd_setImage(with: url) { (image, error, cache, urls) in
                if (error != nil) {
                    self.imageViewLabel.image = UIImage(named: "error")
                } else {
                    self.imageViewLabel.image = image
                }
            }
        } else {
            self.imageViewLabel.isHidden = true
        }
        
    }
    
    private func setImageView() {
        imageViewLabel.layer.cornerRadius = 10
        imageViewLabel.clipsToBounds = true
    }
    
    
}
