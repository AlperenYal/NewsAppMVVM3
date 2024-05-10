//
//  FavoriteNewsModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 29.04.2024.
//

import Foundation

// MARK: - Favorite News Class
class FavoriteNews {
    // MARK: - Properties
    var favoritedesc: String
    var favoriteurl: String?
    var favoritetitle: String
    var favoriteurlimage : String
    var favoritesource : String
    
    // MARK: - Initializer
    init(favoritetitle: String, favoritedesc: String ,favoriteurl: String? ,  favoriteurlimage : String? , favoritesource : String?) {
        self.favoritedesc = favoritedesc
        self.favoritetitle = favoritetitle
        self.favoriteurl = favoriteurl
        self.favoriteurlimage = favoriteurlimage ?? ""
        self.favoritesource = favoritesource ?? ""
    }
}
