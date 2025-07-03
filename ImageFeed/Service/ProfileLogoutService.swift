//
//  ProfileLogoutService.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 03.07.2025.
//

import Foundation
import WebKit

final class ProfileLogoutService {
   static let shared = ProfileLogoutService()
  
   private init() { }

   func logout() {
      cleanCookies()
       ProfileService.shared.clearProfile()
       OAuth2TokenStorage.shared.clearToken()
       ProfileImageService.shared.clearProfileImage()
       ImagesListService.shared.clearImageList()
   }

   private func cleanCookies() {
      HTTPCookieStorage.shared.removeCookies(since: Date.distantPast)
      WKWebsiteDataStore.default().fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { records in
         records.forEach { record in
            WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {})
         }
      }
   }
}
