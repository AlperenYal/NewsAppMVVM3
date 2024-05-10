//
//  FavoriteNewsCoreData+CoreDataProperties.swift
//  NewsAppMVVM3
//
//  Created by Apple on 6.05.2024.
//
//

import Foundation
import CoreData


extension FavoriteNewsCoreData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteNewsCoreData> {
        return NSFetchRequest<FavoriteNewsCoreData>(entityName: "FavoriteNewsCoreData")
    }

    @NSManaged public var titleTwoLabel: String?
    @NSManaged public var imageView: String?
    @NSManaged public var sourceLabel: String?
    @NSManaged public var titleOneLabel: String?
  
}

extension FavoriteNewsCoreData : Identifiable {

}
