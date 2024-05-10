//
//  SplashContainerView.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//


import UIKit

class SplashContainerView: UIView {
    @IBOutlet weak var splashImageView: UIImageView!
    @IBOutlet weak var loadingLabel: UILabel!
    
    func configureUI() {
        splashImageView.image = UIImage(named: "spinner.gif")
        loadingLabel.text = "Configured cell Loading"
    }
    
}

