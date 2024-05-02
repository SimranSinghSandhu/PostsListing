//
//  LoadingIndicatorViewController.swift
//  Interview Prep
//
//  Created by Simran Sandhu on 02/05/24.
//

import UIKit

class LoadingIndicatorViewController: UIViewController {
    
    // Show Loader in the center of the screen
    lazy var loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Show loader at the bottom the collectionView or Table View
    lazy var bottomLoadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .black
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // Attach Refresh control to any tableView or collectionView
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = .black
        return refreshControl
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureLoadingIndicator()
        configureBottomLoadingIndicator()
    }
    
    // MARK: - Helper Methods
    
    private func configureLoadingIndicator() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(loadingIndicator)
        
        loadingIndicator.startAnimating() // Start animating as soon as added to the view
        
        NSLayoutConstraint.activate([
            layoutGuide.centerXAnchor.constraint(equalTo: loadingIndicator.centerXAnchor),
            layoutGuide.centerYAnchor.constraint(equalTo: loadingIndicator.centerYAnchor)
        ])
    }
    
    private func configureBottomLoadingIndicator() {
        let layoutGuide = view.safeAreaLayoutGuide
        view.addSubview(bottomLoadingIndicator)
        
        NSLayoutConstraint.activate([
            layoutGuide.centerXAnchor.constraint(equalTo: bottomLoadingIndicator.centerXAnchor),
            layoutGuide.bottomAnchor.constraint(equalTo: bottomLoadingIndicator.bottomAnchor, constant: 10)
        ])
    }
}

