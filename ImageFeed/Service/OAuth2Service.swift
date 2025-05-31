//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 25.05.2025.
//

import Foundation

final class OAuth2TokenStorage {
    private let tokenKey = "OAuth2Token"
    var token: String? {
        get {return UserDefaults.standard.string(forKey: tokenKey)}
        set {UserDefaults.standard.set(newValue, forKey: tokenKey)}
    }
}

struct OAuthTokenResponseBody: Decodable {
    let access_token: String
}


final class OAuth2Service {
    // глобальная точка входа
    static let shared = OAuth2Service()
    // приватный конструктор. синглтон должен гарантировать,что в приложении будет единственный экземпляр класса.
    private init() {}
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage()
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    
    // MARK: - Public Methods
    
    func makeOAuthTokenRequest(code: String) -> URLRequest {
        guard  let baseURL = URL(string: "https://unsplash.com") else {
            print("[OAuth2Service] Ошибка: не удалось создать базовый URL")
            preconditionFailure("Ошибка: не удалось создать базовый URL")
        }
        
        guard  let url = URL(
            string: "/oauth/token"
            + "?client_id=\(Constants.accessKey)"         // Используем знак ?, чтобы начать перечисление параметров запроса
            + "&&client_secret=\(Constants.secretKey)"    // Используем &&, чтобы добавить дополнительные параметры
            + "&&redirect_uri=\(Constants.redirectURI)"
            + "&&code=\(code)"
            + "&&grant_type=authorization_code",
            relativeTo: baseURL                           // Опираемся на основной или базовый URL, которые содержат схему и имя хоста
        ) else {
            print("URL не создан")
            preconditionFailure("URL не создан")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        if task != nil {
            task?.cancel()
        }
        let request = makeOAuthTokenRequest(code: code)
        
        let task = urlSession.data(for: request) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let responseBody = try decoder.decode(OAuthTokenResponseBody.self, from: data)
                    let access_token = responseBody.access_token
                    self.tokenStorage.token = access_token
                    completion(.success(access_token))
                    print("Код успешно получен и сохранен")
                } catch {
                    completion(.failure(error))
                    print("Failed to decode: \(error)")
                }
            case .failure(let error):
                completion(.failure(error))
                print("Failed to decode: \(error)")
            }
        }
        
        self.task = task
        task.resume()
        
    }
}
