//
//  HomeHeaderViewModel.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import Foundation

class HomeHeaderViewModel {
    
    var selectedItem : HeaderSelections = .all {
        didSet{
            delegate?.didSelectFilter(selectedIndex: self.selectedItem.rawValue)
        }
    }
    
    weak var delegate : HomeHeaderProtocol?
    public let cellIdentifier = "HomeHeaderCell"
    
    var items : [HeaderSelections] = [.all, .business, .entr, .health , .science, .sports, .techn]

    
}
