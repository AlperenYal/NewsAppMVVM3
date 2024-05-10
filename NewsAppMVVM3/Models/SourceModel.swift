//
//  SourceModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation
import UIKit
// MARK: - Source Details Struct
struct SourceDetails: Codable{
    let id: String
    let name: String
    let description: String
    let url: String
    let category: String
    let language: String
    let country: String
}
// MARK: - Company Sources Struct

struct CompanySources: Codable {
    let status: String
    let sources: [SourceDetails]
}
