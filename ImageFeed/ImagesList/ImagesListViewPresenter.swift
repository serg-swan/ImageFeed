//
//  ImagesListViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 12.07.2025.
//

import Foundation
import UIKit
import Kingfisher

protocol ImagesListViewPresenterProtocol {
    var view: ImagesListViewControllerProtocol? { get set }
    var photos: [Photo] { get set }
    func viewDidLoad(showHUD: Bool)
    func configureImageListCell()
    func didTapLike(at indexPath: IndexPath) -> Bool?
    func loadImage(for photo: Photo, cell: ImagesListCell, indexPath: IndexPath)
}

final class ImagesListViewPresenter: ImagesListViewPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    
    // MARK: - Public Properties
    
    private let imageManager: ImageManagerProtocol
    init(imageManager: ImageManagerProtocol = ImageManager()) {
        self.imageManager = imageManager
    }
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    
    // MARK: - Public Methods
    
    func viewDidLoad(showHUD: Bool) {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        if showHUD {
            UIBlockingProgressHUD.show()
        }
        imagesListService.fetchPhotosNextPage(token) { [weak self] result in
            guard let  self else { return }
            if showHUD {
                UIBlockingProgressHUD.dismiss()
            }
            switch result {
            case .success:
                updateTableWithNewPhotos()
            case .failure(let error):
                print("Error loading initial photos: \(error)")
                
            }
        }
    }
    
    func configureImageListCell() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                print("Получено уведомление о загрузке таблицы!")
                guard let  self  else { return}
                updateTableWithNewPhotos()
            }
    }
    
    func didTapLike(at indexPath: IndexPath) -> Bool? {
        guard indexPath.row < photos.count else { return nil }
        let photoId = photos[indexPath.row].id
        let newLikeStatus = !photos[indexPath.row].isLiked
        changeLikeRequest(photoId: photoId, newStatus: newLikeStatus)
        photos[indexPath.row].isLiked = newLikeStatus
        return newLikeStatus
    }
    
    func loadImage(for photo: Photo, cell: ImagesListCell, indexPath: IndexPath) {
        guard let url = URL(string: photo.thumbImageURL) else { return }
        let oldSize = photo.size
        imageManager.updateImage(
            url: url,
            imageView: cell.imageCell,
            placeholderImage: UIImage(named: "placeholderImageCell"),
            processor: nil)
        { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let image):
                if oldSize != image.size {
                    self.updatePhotoSize(at: indexPath, newSize: image.size)
                }
            case .failure(let error):
                print("Error loading image: \(error.localizedDescription)")
            }
        }
        
        if let date = photo.createdAt {
            cell.dateLabel.text = DateFormatter.russianMediumDate.string(from: date)
        } else {
            cell.dateLabel.text = ""
        }
        
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        cell.likeButton.setImage(likeImage, for: .normal)
    }
    
    // MARK: - Private Methods
    
    private func updateTableWithNewPhotos() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard newCount > oldCount else { return }
        photos = imagesListService.photos
        view?.updateTableViewAnimated(oldCount, newCount)
    }
    
    private func changeLikeRequest(photoId: String, newStatus: Bool) {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        UIBlockingProgressHUD.show()
        imagesListService.changeLike(token, photoId: photoId, isLike: newStatus) { [weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    guard let self else {return}
                    self.photos = self.imagesListService.photos
                case .failure:
                    print("Error")
                }
                
            }
        }
    }
    
    private func updatePhotoSize(at indexPath: IndexPath, newSize: CGSize) {
        guard indexPath.row < photos.count else { return }
        photos[indexPath.row].size = newSize
        view?.reloadRow(at: indexPath)
    }
    
}
