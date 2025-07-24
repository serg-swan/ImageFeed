//
//  ProfileResult.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 22.06.2025.
//

import Foundation
struct ProfileResult: Codable {
    let username: String
    var firstName: String?
    var lastName: String?
    var bio: String?
}
