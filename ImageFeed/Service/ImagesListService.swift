//
//  ImagesListService.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 23.06.2025.
//

import Foundation

final class ImagesListService {
    static let shared = ImagesListService()
    private init() {}
    
    static let didChangeNotification = Notification.Name(rawValue: "ImagesListServiceDidChange")
    private(set) var photos: [Photo] = []
    private var lastLoadedPage: Int?
    let token =  OAuth2TokenStorage.shared
    private var task: URLSessionTask?
    private let urlSession = URLSession.shared
    
    func clearImageList() {
        photos = []
      }
    
    func changeLike(_ token: String, photoId: String, isLike: Bool, _ completion: @escaping (Result<Void, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        task = nil
        guard let request = makeLikedPhotosRequest(token: token, photoId: photoId, isLike: isLike) else {
            completion(.failure(ImagesListServiseError.InvalidImagesListResponse))
            return
        }
        let task = urlSession.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            defer {
                self.task = nil
            }
            if let error = error {
                completion(.failure(error))
                return
            }
            completion(.success(()))
            if let index = self.photos.firstIndex(where: { $0.id == photoId }) {
                self.photos[index].isLiked.toggle()
            }
        }
        self.task = task
        task.resume()
    }
    
    func makeLikedPhotosRequest (token: String, photoId: String, isLike: Bool ) -> URLRequest? {
        let baseUrl = Constants.defaultBaseURL
        var urlComponents = URLComponents()
        urlComponents.path = "photos/\(photoId)/like"
        let url = baseUrl.appendingPathComponent(urlComponents.path)
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.httpMethod = isLike == true ? "POST" : "DELETE"
        return request
    }
    
    
    
    func makePhotosNextPageRequest (token: String, page: Int? ) -> URLRequest? {
        guard let url = URL(string: "https://api.unsplash.com/photos?page=\(page ?? 1)") else {
            print("Не верный url")
            fatalError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        return request
    }
    
    
    
    func fetchPhotosNextPage(_ token: String, completion: @escaping (Result<[PhotoResult], Error>) -> Void) {
        let nextPage = (lastLoadedPage ?? 0) + 1
        assert(Thread.isMainThread)
        guard task == nil else {return}
        
        guard let request = makePhotosNextPageRequest(token: token, page: nextPage) else {
            completion(.failure(ImagesListServiseError.InvalidImagesListResponse))
            return
        }
        lastLoadedPage = nextPage
        let task = urlSession.objectTask(for: request) { [weak self] (result: Result<[PhotoResult], Error>) in
            defer {
                self?.task = nil
            }
            switch result {
            case .success(let photoResults):
                let newPhotos = photoResults.map { Photo(from: $0) }
                
                self?.photos.append(contentsOf: newPhotos)
                completion(.success(photoResults))
                NotificationCenter.default
                    .post(
                        name: ImagesListService.didChangeNotification,
                        object: self,
                        userInfo: ["Фото": photoResults ])
            case .failure(let error):
                
                print("[ImagesListService][fetchPhotosNextPage] Error: \(error) ")
                completion(.failure(error))
            }
        }
        self.task = task
        task.resume()
    }
    
}
