//
//  ArticleModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation
import UIKit

// MARK: - Status Enum
enum Status: String {
    case error
    case ok
}

// MARK: - News Struct
struct News: Codable {
    let status: String?
    let totalResults: Int?
    let articles: [Article]?
}

// MARK: - Article Struct
struct Article: Codable {
    var titleOneLabel: String?
    var url: String?
    var imageView: URL?
    var titleTwoLabel: String?
    var sourceLabel: Source? // Changed to Source type
    var publishedAt: String?
    var isFavorite: Bool = false
    
    private enum CodingKeys: String, CodingKey {
        case titleOneLabel = "title"
        case url = "url"
        case imageView = "urlToImage"
        case titleTwoLabel = "description"
        case sourceLabel = "source"
        case publishedAt = "publishedAt"
    }
}

// MARK: - Source Struct
struct Source: Codable {
    let id: String?
    let name: String?
    
    init(id: String?, name: String?) {
        self.id = id
        self.name = name
    }
}
