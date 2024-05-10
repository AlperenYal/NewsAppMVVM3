//
//  HomeHeader.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import UIKit
// MARK: - Home Header Protocol
protocol HomeHeaderProtocol : AnyObject {
    func didSelectFilter(selectedIndex: Int)
}
// MARK: - Home Header Class
class HomeHeader: UICollectionReusableView {
    weak var delegate: HomeHeaderProtocol?
    //MARK: - Properties
    let viewModel = HomeHeaderViewModel()
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            self.collectionView.delegate = self
            self.collectionView.dataSource = self
            self.setCollectionLayout()
            self.registerNibs()
        }
    }
    
    //MARK: - Lifecylce
    override func awakeFromNib() {
        super.awakeFromNib()
        setupUI()
    }
    
    
    //MARK: - Functions
    func registerNibs() {
        let collectionViewCell = UINib(nibName: viewModel.cellIdentifier, bundle: nil)
        collectionView.register(collectionViewCell, forCellWithReuseIdentifier: viewModel.cellIdentifier)
    }
    
    func setCollectionLayout() {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        collectionView.collectionViewLayout = layout
    }
    // MARK: - UI Setup
    func setupUI() {
        collectionView.backgroundColor = .systemGray5
    }
    
}

//MARK: - CollectionDelegate
extension HomeHeader : UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let headerSelection = HeaderSelections(rawValue: indexPath.row) else { return }
        viewModel.selectedItem = headerSelection
        collectionView.reloadData()
        delegate?.didSelectFilter(selectedIndex: indexPath.row)
    }
}

//MARK: - CollectionDataSource
extension HomeHeader : UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: viewModel.cellIdentifier, for: indexPath) as? HomeHeaderCell else { fatalError("DEBUG: Could not create cell") }
        cell.textLabel.text = viewModel.items[indexPath.row].title
        cell.backgroundColor = viewModel.selectedItem == viewModel.items[indexPath.row] ? .white : .customGray
        
        return cell
        
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension HomeHeader : UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width : CGFloat = 120
        return CGSize(width: width, height: width/4)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
    }
}


