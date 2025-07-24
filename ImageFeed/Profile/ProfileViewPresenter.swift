//
//  ProfileViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 10.07.2025.
//


import UIKit
import Kingfisher

public protocol ProfileViewPresenterProtocol {
    var view: ProfileViewControllerProtocol? { get set }
    func viewDidLoad()
    func updateAvatar(_ imageView: UIImageView)
    func didTapButton()
}

final class ProfileViewPresenter: ProfileViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ProfileViewControllerProtocol?
    
    // MARK: - Private Properties
    
    private let imageManager: ImageManagerProtocol
    init(imageManager: ImageManagerProtocol = ImageManager()) {
        self.imageManager = imageManager
    }
    private var profileImageServiceObserver: NSObjectProtocol?
    private let profile = ProfileService.shared.profile
    
    // MARK: - Public Methods
    
    func viewDidLoad() {
        guard let profile else { return }
        view?.updateProfileDetails(profile.name, profile.userName, profile.bio)
        profileImageServiceObserver = NotificationCenter.default
            .addObserver(forName: ProfileImageService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                print("Получено уведомление об изменении аватара!")
                guard let  self  else { return}
                view?.updateAvatar()
            }
    }
    
    func updateAvatar(_ imageView: UIImageView) {
        guard let profileImageURL = ProfileImageService.shared.avatarURL,
              let url = URL(string: profileImageURL)
        else { return }
        let placeholderImage =  UIImage(systemName: "person.crop.circle.fill")
        let processor = RoundCornerImageProcessor(cornerRadius: 16)
        imageManager.updateImage(url: url, imageView: imageView, placeholderImage: placeholderImage, processor: processor, completion: nil)
    }
    func didTapButton() {
        ProfileLogoutService.shared.logout()
        view?.showOut()
    }
    
}
