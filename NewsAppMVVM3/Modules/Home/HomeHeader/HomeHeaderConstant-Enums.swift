//
//  HomeHeaderConstant-Enums.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation
enum HeaderSelections: Int {
    case all, business, entr, health, science, sports, techn
    
    var name : String {
        switch self {
        case .all : return "GENERAL"
        case .business : return "BUSINESS"
        case .entr : return "ENTERTAINMENT"
        case .health : return "HEALTH"
        case .science : return "SCIENCE"
        case .sports : return "SPORTS"
        case .techn : return "TECHNOLOGY"
            
        }
    }
    var title : String {
        switch self {
        case .all : return "GENERAL"
        case .business : return "BUSINESS"
        case .entr : return "ENTERTAINMENT"
        case .health : return "HEALTH"
        case .science : return "SCIENCE"
        case .sports : return "SPORTS"
        case .techn : return "TECHNOLOGY"
        }
    }
}
