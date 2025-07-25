//
//  ProfileImageService.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 08.06.2025.
//

import Foundation

final class ProfileImageService {
    static let shared = ProfileImageService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ProfileImageProviderDidChange")
    private(set) var avatarURL: String?
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    let token =  OAuth2TokenStorage.shared
    
    func clearProfileImage() {
        avatarURL = nil
      }
    
    func makeProfileImageRequest (token: String) -> URLRequest? {
        let baseUrl = Constants.defaultBaseURL
        var urlComponents = URLComponents()
        urlComponents.path = "/me"
        let url = baseUrl.appendingPathComponent(urlComponents.path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    func fetchProfileImageURL(_ token: String, completion: @escaping (Result<UserResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        guard let token = self.token.token else {
            print("Нет токена")
            return}
        guard let request =  makeProfileImageRequest(token: token) else {
            completion(.failure(ProfileServiceError.invalidProfileRequest))
            return
        }
        
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<UserResult, Error>) in
            defer {
                self?.task = nil
            }
            switch result {
            case .success(let data):
                
                let avatarURL = data
                self?.avatarURL = avatarURL.profileImage.small

                    completion(.success(avatarURL))
                
                NotificationCenter.default
                    .post(
                        name: ProfileImageService.didChangeNotification,
                        object: self,
                        userInfo: ["avatarURL": avatarURL ])
                print("avatarURL обновлен \(avatarURL)")
                
            case .failure(let error):
                print("[ProfileImageService][fetchProfileImageURL] Error: \(error) ")
                    completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
}
