//
//  WebViewViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 19.05.2025.
//
import UIKit
import WebKit
import Foundation



public protocol WebViewViewControllerProtocol: AnyObject {
    var presenter: WebViewPresenterProtocol? { get set }
    func load(request: URLRequest)
    func setProgressValue(_ newValue: Float)
    func setProgressHidden(_ isHidden: Bool)
    
}

// MARK: -  WebViewViewControllerDelegate
// на это  протокол подписан AuthViewController
protocol WebViewViewControllerDelegate: AnyObject {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String)
    func webViewViewControllerDidCancel(_ vc: WebViewViewController)
}

// MARK: -  WebViewViewController

final class WebViewViewController: UIViewController, WebViewViewControllerProtocol {
    
    var presenter: WebViewPresenterProtocol?
    
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
        webView.accessibilityIdentifier = "UnsplashWebView"
        webView.navigationDelegate = self
        presenter?.viewDidLoad()
        estimatedProgressObservation = webView.observe(
            \.estimatedProgress,
             options: [],
             changeHandler: { [weak self] _, _ in
                 guard let self else { return }
                 presenter?.didUpdateProgressValue(webView.estimatedProgress)
             })
    }
    
    // MARK: - IBActions
    
    @IBAction private func didTapBackButton() {
        dismiss(animated: true, completion: nil)
    }
    // MARK: - Public methods
    
    func load(request: URLRequest) {
        webView.load(request)
    }
    func setProgressValue(_ newValue: Float) {
        progressView.progress = newValue
    }
    func setProgressHidden(_ isHidden: Bool) {
        progressView.isHidden = isHidden
    }

    // MARK: - Private methods
    
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
          if  let url = navigationAction.request.url{
              self.code = true
            return presenter?.code(from: url)
            }
           return nil
    }
    
}

