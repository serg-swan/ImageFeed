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
    
    @IBOutlet private weak var webView: WKWebView!
    @IBOutlet private weak var progressView: UIProgressView!
    
    // MARK: - Public Properties
    private var estimatedProgressObservation: NSKeyValueObservation?
    weak var delegate: WebViewViewControllerDelegate?
    private var code = false
    // MARK: - Deinitialization
    deinit {
        estimatedProgressObservation = nil  //прекращается наблюдение
    }
    
    // MARK: - Lifecycle
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        webView.navigationDelegate = self
        loadAuthView()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self = self else { return }
                 self.updateProgress()
             })
    }
    
    // MARK: - IBActions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Private methods
    
    private func updateProgress() {
        progressView.progress = Float(webView.estimatedProgress)
        progressView.isHidden = fabs(webView.estimatedProgress - 1.0) <= 0.0001
    }
    
    private  func alertPresenter() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Не удалось войти в систему",
                                      preferredStyle: .alert)
        let action = UIAlertAction(title: "OK",
                                   style: .default)
        print("Алерт показан")
        alert.addAction(action)
        present(alert, animated: true)
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
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        guard !code else { return }
        alertPresenter()
    }
    
    private func code(from navigationAction: WKNavigationAction) -> String? {
        guard
            let url = navigationAction.request.url,
            let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
            let code = components.queryItems?.first(where: { $0.name == "code" })?.value
        else {
            return nil
        }
        self.code = true
        return code
    }
    
}

