//
//  HomeHeaderCellCollectionViewCell.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//


import UIKit

class HomeHeaderCell: UICollectionViewCell {
    //MARK: - Properties
    @IBOutlet weak var textLabel: UILabel!
    
    //MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 5
        clipsToBounds = true
        
    }
    //MARK: - Configure
    func configureUI() {
    }
    
}
