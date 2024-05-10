//
//  ViewController.swift
//  NewsAppMVVM3
//
//  Created by Apple on 18.04.2024.
//

import UIKit

// MARK: - Splash View Controller Protocol
protocol SplashViewControllerProtocol : AnyObject {
    func datasReceived(error: String?)
}

// MARK: - Splash View Controller
class SplashViewController: UIViewController {
    // MARK: - Propertie
    let viewModel = SplashViewModel()
    
    @IBOutlet weak var splashLabel: UILabel!
    @IBOutlet weak var splashImage: UIImageView!
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        viewModel.delegate = self
    }
    // MARK: - UI Configuration
    func configureUI() {
        splashImage.image = UIImage(named:"loading")
        splashLabel.text = "Loading..."
    }
    
}

// MARK: - SplashViewController Protocol Implementation
extension SplashViewController : SplashViewControllerProtocol {
    func datasReceived(error : String?) {
        if let error {
            debugPrint("An error has occured",error)
        }else {
            DispatchQueue.main.async { [weak self] in
                print("DEBUG5: Trying to fetch data")
                guard let identifier = self?.viewModel.segueIdentifier else { return }
                self?.performSegue(withIdentifier: identifier, sender: self?.viewModel.articlesArray)
            }
        }
    }
}


//MARK: - Segue
extension SplashViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is MainTabController {
            guard let data = sender as? [Article] else { return }
            if let tabBarController = segue.destination as? UITabBarController,
               let navController = tabBarController.viewControllers?.first as? UINavigationController,
               let firstTabVc = navController.viewControllers.first as? HomeController {
                firstTabVc.viewModel.articlesArray = data
            }
        }
    }
}

