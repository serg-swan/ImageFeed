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
    static let redirectURI: String = "urn:ietf:wg:oauth:2.0:oob"
    static let accessScope: String = "public+read_user+write_likes"
    
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
    static let defaultBaseURL: URL = {
        guard let url = URL(string: "https://api.unsplash.com") else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
}
struct AuthConfiguration {
    let accessKey: String
    let secretKey: String
    let redirectURI: String
    let accessScope: String
    let defaultBaseURL: URL
    let authURLString: String

    init(accessKey: String, secretKey: String, redirectURI: String, accessScope: String, authURLString: String, defaultBaseURL: URL) {
        self.accessKey = accessKey
        self.secretKey = secretKey
        self.redirectURI = redirectURI
        self.accessScope = accessScope
        self.defaultBaseURL = defaultBaseURL
        self.authURLString = authURLString
    }
    static var standard: AuthConfiguration {
           return AuthConfiguration(accessKey: Constants.accessKey,
                                    secretKey: Constants.secretKey,
                                    redirectURI: Constants.redirectURI,
                                    accessScope: Constants.accessScope,
                                    authURLString: Constants.unsplashAuthorizeURLString,
                                    defaultBaseURL: Constants.defaultBaseURL)
       }
}
