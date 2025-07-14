//
//  WebViewPresenter.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 06.07.2025.
//

import Foundation

enum WebViewConstants {
 
}

public protocol WebViewPresenterProtocol {
    var view: WebViewViewControllerProtocol? { get set }
    func viewDidLoad()
    func didUpdateProgressValue(_ nevValue: Double)
    func code(from url: URL) -> String?
}

final class WebViewPresenter: WebViewPresenterProtocol {
    var authHelper: AuthHelperProtocol
    init(authHelper: AuthHelperProtocol) {
        self.authHelper = authHelper
    }
    weak var view: WebViewViewControllerProtocol?
   
    func viewDidLoad() {
        guard let request = authHelper.authRequest() else { return }
        didUpdateProgressValue(0)
        view?.load(request: request)
    }
    
    func didUpdateProgressValue(_ nevValue: Double) {
        let newProgressValue = Float(nevValue)
        view?.setProgressValue(newProgressValue)
        let shouldHideProgress = shouldHideProgress(for: newProgressValue)
        view?.setProgressHidden(shouldHideProgress)
    }
    
    func shouldHideProgress(for value: Float) -> Bool {
        abs(value - 1.0) <= 0.0001
    }
    
    func code(from url: URL) -> String? {
        authHelper.code(from: url)
    }
}
