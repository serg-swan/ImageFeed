//
//  TabBarController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 17.06.2025.
//

import Foundation
import UIKit

final class TabBarController: UITabBarController {
    override func awakeFromNib() {
        super.awakeFromNib()
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let imagesListViewController = storyboard.instantiateViewController(
            withIdentifier: "ImagesListViewController") as? ImagesListViewController else {
            fatalError("Failed to instantiate ImagesListViewController")
        }
        let imagesListViewPresenter = ImagesListViewPresenter()
        imagesListViewController.configure(imagesListViewPresenter)
        
        let profileViewController = ProfileViewController()
        let profileViewPresenter = ProfileViewPresenter()
        profileViewController.configure(profileViewPresenter)
        profileViewController.tabBarItem = UITabBarItem(
            title: "",
            image: UIImage(named:"tab_profile_active"),
            selectedImage: nil
        )
        self.viewControllers = [imagesListViewController, profileViewController]
    }
}
