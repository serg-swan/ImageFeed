//
//  PhotoResult.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 24.06.2025.
//

import Foundation

struct PhotoResult: Codable {
    let id: String
    let createdAt: Date?
    let width: Int
    let height: Int
    let description: String?
    let user: ProfileResult
    let urls: UrlsResult
    let likedByUser: Bool
}
