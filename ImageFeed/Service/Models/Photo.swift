//
//  Photo.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 23.06.2025.
//

import Foundation
struct Photo {
    let id: String
    var size: CGSize
    let createdAt: Date?
    var welcomeDescription: String?
    let thumbImageURL: String
    let largeImageURL: String
    var isLiked: Bool
    
    init(from result: PhotoResult) {
        self.id = result.id
        self.size = CGSize(width: result.width, height: result.height)
        self.createdAt = result.createdAt.flatMap(DateFormatter.iso8601Formatter.date(from:))
        self.welcomeDescription = result.description
        self.thumbImageURL = result.urls.thumb
        self.largeImageURL = result.urls.regular
        self.isLiked = result.likedByUser
    }
}
