//
//  SearchDetailsCell.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import UIKit

class SearchDetailsCell: UITableViewCell {
    
    var article : Article? {
        didSet {
            configureUI()
        }
    }
    
    @IBOutlet weak var headImage: UIImageView!
    
    @IBOutlet weak var sourceLabel: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    

//    @IBOutlet weak var headImage: UIImageView!
//
//    @IBOutlet weak var sourceLabel: UILabel!
//
//    @IBOutlet weak var descriptionLabel: UILabel!
    
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    
    func configureUI() {
        guard let article = article else { return }
        headImage.sd_setImage(with: article.imageView)
        sourceLabel.text = article.sourceLabel?.name
        descriptionLabel.text = article.titleTwoLabel
        headImage.layer.cornerRadius = 10
        headImage.clipsToBounds = true
    }
    
}
