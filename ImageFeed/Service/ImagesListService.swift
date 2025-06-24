//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 23.06.2025.
//

import Foundation

final class ImagesListService {
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    let token =  OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    
    func makePhotosNextPageRequest (token: String, page: Int? ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page ?? 1)") else {
            print("Не верный url")
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<PhotoResult, Error>) -> Void) {
        let nextPage = (lastLoadedPage ?? 0) + 1
        
        assert(Thread.isMainThread)
        guard task == nil else {return}
        
        guard let token = self.token.token   else {
            print("Нет токена")
            return
        }
        guard let request = makePhotosNextPageRequest(token: token, page: nextPage) else {
            completion(.failure(ImagesListServiseError.InvalidImagesListResponse))
            return
        }
        
    let task = urlSession.objectTask(for: request) { [weak self] (result: Result<PhotoResult, Error>) in
            defer {
                self?.task = nil
            }
            switch result {
            case .success(let data):
               
                let photoResult = data
                let photo = Photo(from: photoResult)
                self?.photos.append(photo)
                    completion(.success(photoResult))
                print("Фото загружено")
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Фото": photo ])
                print("Фото загружены  \(photo)")
                
            case .failure(let error):
                print("[ImagesListService][fetchPhotosNextPage] Error: \(error) ")
                    completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
}


