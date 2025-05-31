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
