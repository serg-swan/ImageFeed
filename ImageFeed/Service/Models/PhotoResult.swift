//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 24.06.2025.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: String
    let width: CGFloat
    let height: CGFloat
    let description: String?
    let urls: UrlsResult
    let likedByUser: Bool
}
