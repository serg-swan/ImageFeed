//
//  Constants.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 17.05.2025.
//

import Foundation

enum Constants {
    static let accessKey: String = "4bs14REqj2Q8m8DnZHcsImNBz1QdTyH0WnfMliP8NOU"
    static let secretKey: String = "HED7t0LaUva-hvj9Wv34JkzURSmWM1bv4Wg4FxVpPKo"
    static let redirectURI :String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    static let defaultBaseURL: URL = URL(string: "https://api.unsplash.com")!
}
