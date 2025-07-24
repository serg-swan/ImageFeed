//
//  SplashViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 26.05.2025.
//

import UIKit

final class SplashViewController: UIViewController {
    
    // MARK: - Private Properties
    private let profileImageService = ProfileImageService.shared
    private let profileService = ProfileService.shared
    private let showAuthenticationScreenSegueIdentifier = "ShowAuthenticationScreen"
    private let storage = OAuth2TokenStorage.shared
    private let splashScreenView = UIImageView()
    
    //MARK: - Lifecycle
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupUI()
        checkToken()
        guard let token = storage.token else {return}
        fetchProfile(token)
    }
    
    // MARK: - Public Methods
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNeedsStatusBarAppearanceUpdate()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .lightContent
    }
    
    // MARK: - Private Methods
    private func segueAuthViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        guard let authViewController = storyboard.instantiateViewController(
            withIdentifier: "AuthViewController"
        ) as? AuthViewController else { return }
        
        authViewController.delegate = self
        authViewController.modalPresentationStyle = .fullScreen
        present(authViewController, animated: true)
    }
    private func setupUI() {
        view.backgroundColor = UIColor(named: "YP Black (iOS)")
        view.addSubview(splashScreenView)
        splashScreenView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            splashScreenView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            splashScreenView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func  checkToken()  {
        guard let token = storage.token else {
            print ("Нет токена")
            return segueAuthViewController()
            
        }
        print("Токен есть: \(token)")
        fetchProfile(token)
    }
    
    private func switchToTabBarController() {
        guard let window = UIApplication.shared.windows.first else { fatalError("Invalid Configuration") }
        let tabBarController = UIStoryboard(name: "Main", bundle: .main)
            .instantiateViewController(withIdentifier: "TabBarViewController")
        window.rootViewController = tabBarController
    }
    func fetchProfile(_ token: String) {
        UIBlockingProgressHUD.show()
        profileService.fetchProfile(token) { [weak self] result in
            UIBlockingProgressHUD.dismiss()
            guard let self else { return }
            switch result {
            case .success:
                self.switchToTabBarController()
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error)")
            }
        }
        profileImageService.fetchProfileImageURL(token) { [weak self] result in
            guard  self != nil  else { return }
            switch result {
            case .success:
                print("Загрузка аватара профиля успешна")
            case .failure(let error):
                print("Ошибка загрузки профиля: \(error)")
            }
        }
    }
   
}

extension SplashViewController: AuthViewControllerDelegate {
    func didAuthenticate(_ vc: AuthViewController) {
        vc.dismiss(animated: true)
        guard let token = storage.token else {return}
        fetchProfile(token)
    }
}
