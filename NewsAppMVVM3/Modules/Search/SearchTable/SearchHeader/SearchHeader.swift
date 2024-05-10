//
//  SearchHeaderController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//
import UIKit
// MARK: - Search Header Protocol
protocol SearchHeaderSearchBarProtocol : AnyObject{
    func searchHeaderDidTapSend(searchText: String)
}
// MARK: - Search Header Class
class SearchHeader: UITableViewHeaderFooterView {
    // MARK: - Properties
    let viewModel = SearchHeaderViewModel()
    var debounceTimer: Timer?
    
    @IBOutlet weak var searchBar: UISearchBar! {
        didSet {
            searchBar.delegate = self
        }
    }
    //MARK: - Lifecylce
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
}
// MARK: - UISearchBarDelegate
extension SearchHeader: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.showsCancelButton = false
    }
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { [weak self] _ in
            self?.viewModel.delegate?.searchHeaderDidTapSend(searchText: searchText)
        })
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        searchBar.resignFirstResponder()
        viewModel.delegate?.searchHeaderDidTapSend(searchText: text)
        searchBar.showsCancelButton = false
    }
}









