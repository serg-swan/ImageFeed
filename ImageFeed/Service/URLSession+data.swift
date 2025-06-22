//
//  URLSession+data.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 25.05.2025.
//

import Foundation

enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case decodingError(Error)
}
extension URLSession {
    func objectTask<T: Codable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<T, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let task = data(for: request) { (result: Result<Data, Error>)   in
            switch result {
            case .success(let data):
                do {
                    let decodetJsonObject = try decoder.decode(T.self, from: data)
                    fulfillCompletionOnTheMainThread(.success(decodetJsonObject))
                    print("JSON раскодирован")
                }
                
                catch{
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.decodingError(error)))
                    print("Ошибка декодирования: \(error.localizedDescription), Данные: \(String(data: data, encoding: .utf8) ?? "")")
                }
                
            case .failure(let error):
                fulfillCompletionOnTheMainThread(.failure(error))
                print("Ошибка загрузки  \(error)")
            }
        }
        return task
    }
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            guard let data = data,
                  let response = response as? HTTPURLResponse else {
                if let error = error {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error)))
                    print("[Network] Ошибка запроса: \(error.localizedDescription)")
                } else {
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError))
                    print("[Network] Неизвестная ошибка сессии")
                }
                return
            }
            
            let statusCode = response.statusCode
            
            guard (200...299).contains(statusCode) else {
                fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode)))
                print("[Network] Ошибка HTTP: статус \(statusCode)")
                return
            }
            
            fulfillCompletionOnTheMainThread(.success(data))
            
        })
        
        return task
    }
}
