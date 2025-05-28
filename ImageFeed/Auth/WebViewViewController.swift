//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 19.05.2025.
//
import UIKit
import WebKit
import Foundation

enum WebViewConstants {
    static let unsplashAuthorizeURLString = "https://unsplash.com/oauth/authorize"
}

// MARK: -  WebViewViewControllerDelegate
// на это  протокол подписан AuthViewController
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: -  WebViewViewController

final class WebViewViewController: UIViewController {
    
    // MARK: - IBOutlets
    
    @IBOutlet private  var webView: WKWebView!
    @IBOutlet private var progressView: UIProgressView!
    
    // MARK: - Public Properties
    
    weak var delegate: WebViewViewControllerDelegate?
    
    // MARK: - Lifecycle
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        
    }
    
    // MARK: - IBActions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    // добавляем наблюдатель
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        webView.addObserver(
            self,
            forKeyPath: #keyPath(WKWebView.estimatedProgress),
            options: .new,
            context: nil)
        updateProgress()
    }
    // MARK: - Public methods
    
    //удаляем наблюдатель
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
    }
    // метод обработчик обновлений
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            updateProgress()
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    // MARK: - Private methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private func loadAuthView() {
        // Мы инициализируем структуру URLComponents с указанием адреса запроса.
        guard var urlComponents = URLComponents(string: WebViewConstants.unsplashAuthorizeURLString) else {
            print("адрес https://unsplash.com/oauth/authorize не верный ")
            return }
        
        urlComponents.queryItems = [
            
            URLQueryItem(name: "client_id", value: Constants.accessKey),
            URLQueryItem(name: "redirect_uri", value: Constants.redirectURI),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: Constants.accessScope)
        ]
        
        guard let url = urlComponents.url else {
            return }
        print("url \(url)")
        let request = URLRequest(url: url)
        webView.load(request)
        updateProgress()
        
    }
}

extension WebViewViewController: WKNavigationDelegate {
    // релизация метода протокола. Этот метод вызывается, когда в результате действий пользователя WKWebView готовится совершить навигационные действия (например, загрузить новую страницу). Благодаря этому мы узнаем, когда пользователь успешно авторизовался.
    func webView(
        _ webView: WKWebView,
        decidePolicyFor navigationAction: WKNavigationAction,
        decisionHandler: @escaping (WKNavigationActionPolicy) -> Void
    ) {
        
        if let code = code(from: navigationAction) {
            delegate?.webViewViewController(self, didAuthenticateWithCode: code)
            decisionHandler(.cancel)
            print ("код  получен")
        } else {
            decisionHandler(.allow)
            print ("код не получен")
        }
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        
        guard
            let url = navigationAction.request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false), //указывает, что не нужно учитывать базовый URL при разборе
            //  /oauth/authorize/native не проверяется тк оличается redirect_uri
                let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return nil
        }
        return code
    }
    
}
