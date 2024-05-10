//
//  FavoriteNewsCoreData+CoreDataClass.swift
//  NewsAppMVVM3
//
//  Created by Apple on 6.05.2024.
//
//

import Foundation
import CoreData



public class FavoriteNewsCoreData: NSManagedObject {
    @NSManaged public var title: String
    @NSManaged public var descriptionText: String
    @NSManaged public var image: String?
    @NSManaged public var source: String
    @NSManaged public var url: String?

}



func mapToFavoriteNewsCoreData(from newsArticle: Article) -> FavoriteNewsCoreData {
    let favoriteNews = FavoriteNewsCoreData()
    favoriteNews.title = newsArticle.titleOneLabel ?? ""
    favoriteNews.descriptionText = newsArticle.titleTwoLabel ?? ""
    favoriteNews.source = newsArticle.sourceLabel?.name ?? ""
    favoriteNews.url = newsArticle.url ?? ""
    favoriteNews.image = (newsArticle.imageView ?? URL(string: ""))?.absoluteString
    return favoriteNews
}



