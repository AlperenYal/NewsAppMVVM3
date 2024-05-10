//
//  HomeCellDetailsControllerViewController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//
import UIKit
import WebKit

// MARK: - Home Details Controller
class HomeDetailsController: UIViewController {
    //MARK: - Properties
    let viewModel = HomeDetailViewModel()
    var webView: WKWebView!
    var urlString: String?
    
    init(urlString: String?) {
        self.urlString = urlString
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) {
        self.urlString = ""
        super.init(coder: coder)
    }
    @IBOutlet weak var tableView: UITableView! {
        didSet {
            self.tableView.delegate = self
            self.tableView.dataSource = self
            self.registerNibs()
        }
    }
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupWebView()
        loadWebViewContent()
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
        
        if let urlString = self.urlString,
           let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    private func setupWebView() {
        webView = WKWebView(frame: view.bounds)
        view.addSubview(webView)
    }
    private func loadWebViewContent() {
        if let urlString = viewModel.article?.url, let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    // MARK: - UI Configuration
    private func registerNibs() {
        let tableViewCellNib = UINib(nibName: viewModel.cellIdentifier, bundle: nil)
        tableView.register(tableViewCellNib, forCellReuseIdentifier: viewModel.cellIdentifier)
    }
}
//MARK: - TableViewDelegate
extension HomeDetailsController : UITableViewDelegate {
}
//MARK: - TableViewDatasource
extension HomeDetailsController : UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: viewModel.cellIdentifier, for: indexPath) as? DetailsCell else {
            fatalError("DEBUG: Could not created detailscell")
        }
        cell.article = viewModel.article
        return cell
    }
}



