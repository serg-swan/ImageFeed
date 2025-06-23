//
//  Profile.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 22.06.2025.
//

import Foundation
struct Profile {
    let userName: String
    let name: String
    let loginName: String
    let bio: String
    init(from result: ProfileRsult){
        self.userName = result.username
        self.name = "\(result.firstName ?? "") \(result.lastName ?? "")"
        self.loginName = "@" + result.username
        self.bio = result.bio ?? ""
    }
}
