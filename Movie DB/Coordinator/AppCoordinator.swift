//
//  AppCoordinator.swift
//  Movie DB
//
//  Created by Nika Kirkitadze on 9/26/20.
//

import UIKit

final class AppCoordinator: Coordinator {
    
    // MARK: - Properties
    private let navController: UINavigationController
    private let window: UIWindow
    
    // MARK: - Initializer
    init(navController: UINavigationController, window: UIWindow) {
        self.navController = navController
        self.window = window
    }
    
    func start() {
        window.rootViewController = navController
        window.makeKeyAndVisible()
        showMain()
    }
    
    // MARK: - Navigation
    private func showMain() {
        let sb = AppStoryboard.main.instance
        let mainVC = sb.instantiate(viewController: MainViewController.self)
        mainVC.delegate = self
        navController.setViewControllers([mainVC], animated: true)
    }
    
    private func pushDetails(showId: Int) {
        let sb = AppStoryboard.details.instance
        let detailsVC = sb.instantiate(viewController: DetailsViewController.self)
        detailsVC.delegate = self
        detailsVC.showId = showId
        navController.pushViewController(detailsVC, animated: true)
    }
}

// MARK: - MainViewControllerDelegate
extension AppCoordinator: MainViewControllerDelegate {
    func openDetails(showId: Int) {
        pushDetails(showId: showId)
    }
}

// MARK: DetailsViewControllerDelegate?'
extension AppCoordinator: DetailsViewControllerDelegate {

}
