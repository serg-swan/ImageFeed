//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Сергей Лебедь on 07.07.2025.
//

import XCTest
@testable import ImageFeed
final class WebViewTests: XCTestCase {
    
    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "WebViewViewController") as? WebViewViewController
        let presenter = WebViewPresenterSpy()
        viewController?.presenter = presenter
        presenter.view = viewController
        
        _ = viewController?.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    func testPresenterCallsLoadRequest() {
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let viewController = WebViewViewControlerSpy()
        viewController.presenter = presenter
        presenter.view = viewController
        presenter.viewDidLoad()
        XCTAssertTrue(viewController.loadRequestCalled)
    }
    
    func testProgressHiddenWhenOne() {
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 1
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        
        XCTAssertTrue(shouldHideProgress)
    }
    func testProgressVisibleWhenLessThenOne() {
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        let presenter = WebViewPresenter(authHelper: authHelper)
        let progress: Float = 0.6
        let shouldHideProgress = presenter.shouldHideProgress(for: progress)
        
        
        XCTAssertFalse(shouldHideProgress)
    }
    func testAuthHelperAuthURL() {
        let configuration = AuthConfiguration.standard
        let authHelper = AuthHelper(configuration: configuration)
       let url = authHelper.authURL()
        guard let urlString = url?.absoluteString else {
            XCTFail("URL should not be nil")
            return
        }
        XCTAssertTrue(urlString.contains(configuration.authURLString))
           XCTAssertTrue(urlString.contains(configuration.accessKey))
           XCTAssertTrue(urlString.contains(configuration.redirectURI))
           XCTAssertTrue(urlString.contains("code"))
           XCTAssertTrue(urlString.contains(configuration.accessScope))
    }
    
    func testCodeFromURL() {
        //given
        var urlComponents = URLComponents(string: Constants.unsplashAuthorizeURLString)!
        urlComponents.queryItems = [URLQueryItem(name: "code", value: "test code")]
        let url = urlComponents.url!
        let authHelper = AuthHelper(configuration: AuthConfiguration.standard)
        
        //when
        let code = authHelper.code(from: url)
        
        //then
        XCTAssertEqual(code, "test code")
    }
}
    
    final class WebViewViewControlerSpy: WebViewViewControllerProtocol {
        var loadRequestCalled: Bool = false
        func loadRequest(_ request: URLRequest) {
            loadRequestCalled = true
        }
        var presenter: WebViewPresenterProtocol?
        func load(request: URLRequest) {
            loadRequestCalled = true
        }
        func setProgressValue(_ newValue: Float){
            
        }
        func setProgressHidden(_ isHidden: Bool) {
            
        }
    }


final class WebViewPresenterSpy: WebViewPresenterProtocol {
    var viewDidLoadCalled: Bool = false
    var view: WebViewViewControllerProtocol?
    func viewDidLoad() {
        viewDidLoadCalled = true
    }
    func didUpdateProgressValue(_ nevValue: Double) {
        
    }
    
    func code(from url: URL) -> String? {
        return nil
    }
}
