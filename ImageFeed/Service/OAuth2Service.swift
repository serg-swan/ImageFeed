//
//  OAuth2Service.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 25.05.2025.
//

import Foundation
import UIKit
import SwiftKeychainWrapper

final class OAuth2Service {
    // глобальная точка входа
    static let shared = OAuth2Service()
    // приватный конструктор. синглтон должен гарантировать,что в приложении будет единственный экземпляр класса.
    private init() {}
    
    // MARK: - Private Properties
    
    private let tokenStorage = OAuth2TokenStorage.shared
    private let urlSession = URLSession.shared
    private var task: URLSessionTask?
    private var lastCode: String?
    
    // MARK: - Public Methods
   
    
    func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard  let baseURL = URL(string: "https://unsplash.com") else {
            print("[OAuth2Service] Ошибка: не удалось создать базовый URL")
            assertionFailure("Failed to create URL")
            return nil
        }
        var urlComponents = URLComponents()
        urlComponents.path = "/oauth/token"
        urlComponents.queryItems = [
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "client_secret", value: Constants.secretKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "grant_type", value: "authorization_code")
            ]
        
        guard  let url = urlComponents.url(relativeTo: baseURL) else {
            print("URL не создан")
            preconditionFailure("URL не создан")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        return request
    }
    
    func fetchOAuthToken(_ code: String, completion: @escaping (Swift.Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        
        guard lastCode != code else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        task?.cancel()
        lastCode = code
        guard let request = makeOAuthTokenRequest(code: code)
        else {
            completion(.failure(AuthServiceError.invalidRequest))
            return
        }
        let task = urlSession.objectTask(for: request) { [weak self]  (result: Result<OAuthTokenResponseBody, Error>) in
            defer {
                self?.task = nil
                self?.lastCode = nil
            }
            switch result {
            case .success(let data):
                    let accessToken =  data.accessToken
                    self?.tokenStorage.token = accessToken
                    DispatchQueue.main.async {
                        completion(.success(accessToken))
                    }
                    print("Код успешно получен и сохранен")
            case .failure(let error):
                print("[OAuth2Service][fetchOAuthToken] Error: \(error) ")
                    completion(.failure(error))
                
            }
        }
        self.task = task
        task.resume()
    }
}
