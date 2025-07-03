//
//  OAuth2TokenStorage.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 22.06.2025.
//

import Foundation
import SwiftKeychainWrapper

final class OAuth2TokenStorage {
    static let shared = OAuth2TokenStorage()
    private init() {}
    
    private let tokenKey = "OAuth2Token"
    var token: String? {
        get { return KeychainWrapper.standard.string(forKey: tokenKey)}
        set { guard let newValue else {
            print("Токен не сохранен")
            return
        }
            KeychainWrapper.standard.set(newValue, forKey: tokenKey)}
    }
    
    func clearToken() {
        KeychainWrapper.standard.removeObject(forKey: tokenKey)
        token = nil
    }
}
