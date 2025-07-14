//
//  Image_FeedUITests.swift
//  Image FeedUITests
//
//  Created by Сергей Лебедь on 14.07.2025.
//

import XCTest

final class Image_FeedUITests: XCTestCase {

    private let app = XCUIApplication()
     
     override func setUpWithError() throws {
         continueAfterFailure = false
         
         app.launch()
     }
     
     func testAuth() throws {
         app.buttons["Authenticate"].tap()
            
            let webView = app.webViews["UnsplashWebView"]
            
            XCTAssertTrue(webView.waitForExistence(timeout: 9))

            let loginTextField = webView.descendants(matching: .textField).element
            XCTAssertTrue(loginTextField.waitForExistence(timeout: 9))
            
            loginTextField.tap()
            loginTextField.typeText("s.lebed8920@yandex.ru")
            webView.swipeUp()
        
            
            let passwordTextField = webView.descendants(matching: .secureTextField).element
            XCTAssertTrue(passwordTextField.waitForExistence(timeout: 9))
            
            passwordTextField.tap()
            passwordTextField.typeText("Imagefeet")
            webView.swipeUp()
            
            webView.buttons["Login"].tap()
            
            let tablesQuery = app.tables
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 1)
            
            XCTAssertTrue(cell.waitForExistence(timeout: 9))
     }
     
     func testFeed() throws {
         let tablesQuery = app.tables
            
            let cell = tablesQuery.children(matching: .cell).element(boundBy: 0)
            cell.swipeUp()
            
            sleep(2)
            
            let cellToLike = tablesQuery.children(matching: .cell).element(boundBy: 1)
            
            cellToLike.buttons["like button off"].tap()
            sleep(1)
            cellToLike.buttons["like button on"].tap()
            
            sleep(2)
            
            cellToLike.tap()
            
            sleep(2)
            
            let image = app.scrollViews.images.element(boundBy: 0)
          
            image.pinch(withScale: 3, velocity: 1)
          
            image.pinch(withScale: 0.5, velocity: -1)
            
            let navBackButtonWhiteButton = app.buttons["nav back button white"]
            navBackButtonWhiteButton.tap()
     }
     
     func testProfile() throws {
         sleep(3)
          app.tabBars.buttons.element(boundBy: 1).tap()
         
          app.buttons["logout button"].tap()
          
          app.alerts["Пока, пока!"].scrollViews.otherElements.buttons["Да"].tap()
     }
}
