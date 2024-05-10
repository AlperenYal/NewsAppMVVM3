//
//  API_Parameters.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation

// MARK: - Article Parameters
struct ArticleParameters {
    let country : String?
    let category : String?
    let source : String?
    
    
    init(country: String? = nil, category: String? = nil, source: String? = nil) {
        self.country = country
        self.category = category
        self.source = source
    }
}

// MARK: - Source Parameters

struct SourceParameters {
    let country : String
    
    init(country: String) {
        self.country = country
    }
}
