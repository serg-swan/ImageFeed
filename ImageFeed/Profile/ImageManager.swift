//
//  AvatarManager.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 11.07.2025.
//


import UIKit
import Kingfisher

protocol ImageManagerProtocol {
    func updateImage(url: URL,
                     imageView: UIImageView,
                     placeholderImage: UIImage?,
                     processor: ImageProcessor?,
                     completion: ((Result<UIImage, Error>) -> Void)?)
}

final class ImageManager: ImageManagerProtocol {
    func updateImage(url: URL, imageView: UIImageView, placeholderImage: UIImage?, processor: ImageProcessor?, completion: ((Result<UIImage, Error>) -> Void)?) {
        DispatchQueue.main.async {
            imageView.kf.indicatorType = .activity
            var options: KingfisherOptionsInfo = []
            if let processor = processor {
                options.append(.processor(processor))
            }
            imageView.kf.setImage(with: url,
                                  placeholder: placeholderImage ,
                                  options: options,
                                  completionHandler: { result in
                switch result {
                case .success(let value):
                    completion?(.success(value.image))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
            )
        }
    }
}
