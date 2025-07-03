//
//  ProfileService.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 04.06.2025.
//

import Foundation

final class ProfileService {
    static let shared = ProfileService()
    private init() {}
    
    // MARK: Private Properties
    
    private(set) var profile: Profile?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    let token =  OAuth2TokenStorage.shared
    
    //MARK: Public Methods
    
    func clearProfile() {
          profile = nil
      }
    
    func makeProfileRequest (token: String) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/me") else {
            print("Не верный url")
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchProfile(_ token: String, completion: @escaping (Result<Profile, Error>) -> Void) {
     
        
        assert(Thread.isMainThread)
        task?.cancel()
        task = nil
        guard let token = self.token.token   else {
            completion(.failure(ProfileServiceError.invalidProfileRequest))
            return
        }
        guard let request = makeProfileRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidProfileRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<ProfileResult, Error>) in
            defer {
                self?.task = nil
            }
            switch result {
            case .success(let data):
                let profile = Profile(from: data)
                self?.profile = profile
                    completion(.success(profile))
                print(profile)
                
            case .failure(let error):
                print("[ProfileService][fetchProfile] Error: \(error) ")
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
        self.task = task
        task.resume()
    }
    
}
