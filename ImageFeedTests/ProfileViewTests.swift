//
//  Image_FeedTests.swift
//  Image FeedTests
//
//  Created by Сергей Лебедь on 13.07.2025.
//

import XCTest
@testable import ImageFeed
final class ProfileView: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
      
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
     
        _ = viewController.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
      
    }
    
    func testViewControllerCallsUpdateAvatar() {
      
        let viewController = ProfileViewController()
        let presenter = ProfileViewPresenterSpy()
        viewController.configure(presenter)
     
        _ = viewController.view
    
        XCTAssertTrue(presenter.updateAvatarCalled)
    }
    
    func testPresenterCallsShowOut() {
       
        let presenter = ProfileViewPresenter(imageManager: ImageManager())
      let viewController = ProfileViewControllerSpy()
        presenter.view = viewController
        viewController.presenter = presenter
        presenter.didTapButton()
    
        XCTAssertTrue(viewController.showOutCalled)
        
    }
    
}

final class ProfileViewControllerSpy: ProfileViewControllerProtocol {
   
    var viewDidLoadCalled = false
    var showOutCalled = false
    var presenter: ProfileViewPresenterProtocol?
    
    func updateProfileDetails(_ name: String, _ userName: String, _ bio: String) {
    
    }
    
    func updateAvatar() {
        
    }
    
    func showOut() {
        showOutCalled = true
    }
    
    
}

final class ProfileViewPresenterSpy: ProfileViewPresenterProtocol {
  
    var updateAvatarCalled = false
    var viewDidLoadCalled: Bool = false
    var view: ProfileViewControllerProtocol?
    
    func viewDidLoad() {
         viewDidLoadCalled = true
    }
    
    func updateAvatar(_ imageView: UIImageView) {
      updateAvatarCalled = true
    }
    
    func didTapButton() {
      
    }
    
}




