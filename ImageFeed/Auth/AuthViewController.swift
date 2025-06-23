//
//  AuthViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 19.05.2025.
//
import UIKit
import ProgressHUD

// на него подписан SplashViewController
protocol AuthViewControllerDelegate: AnyObject {
    func didAuthenticate(_ vc: AuthViewController)
}


final class AuthViewController: UIViewController {
    
    private let showWebViewIdentifier = "ShowWebView"
    weak var delegate: AuthViewControllerDelegate?
    
    // присвоение делегата WebViewViewController
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showWebViewIdentifier {
            guard
                let webViewViewController = segue.destination as? WebViewViewController
            else {
                
                assertionFailure("Failed to prepare for \(showWebViewIdentifier)")
                return
            }
            webViewViewController.delegate = self
        } else {
            super.prepare(for: segue, sender: sender)
        }
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
}
extension AuthViewController: WebViewViewControllerDelegate {
    func webViewViewController(_ vc: WebViewViewController, didAuthenticateWithCode code: String) {
        vc.dismiss(animated: true) // Закрыли WebView
        UIBlockingProgressHUD.show()//
        OAuth2Service.shared.fetchOAuthToken(code) { [weak self] result in
            guard let self else { return }
            switch result {
            case .success:
                self.delegate?.didAuthenticate(self)
                UIBlockingProgressHUD.dismiss()
            case .failure(let error):
                self.alertPresenter()
                UIBlockingProgressHUD.dismiss()
                print("Ошибка получения токена: \(error)")
            }
        }
    }
    func webViewViewControllerDidCancel(_ vc: WebViewViewController) {
        vc.dismiss(animated: true)
    }
    
}
