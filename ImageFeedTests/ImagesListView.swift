//
//  ImageListView.swift
//  Image FeedTests
//
//  Created by Сергей Лебедь on 14.07.2025.
//

import XCTest
@testable import ImageFeed
final class ImagesListView: XCTestCase {

    func testViewControllerCallsViewDidLoad() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        let presenter = ImageslistViewPresenterSpy()
        viewController?.configure(presenter)
       
        _ = viewController?.view
        
        XCTAssertTrue(presenter.viewDidLoadCalled)
    }
    
    func testViewControllerCallsconfigureImageListCell() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let viewController = storyboard.instantiateViewController(withIdentifier: "ImagesListViewController") as? ImagesListViewController
        let presenter = ImageslistViewPresenterSpy()
        viewController?.configure(presenter)
       
        _ = viewController?.view
        
        XCTAssertTrue(presenter.configureImageListCellCalled)
    }
  
}

final class ImagesListViewControllerSpy: ImagesListViewControllerProtocol {
    var presenter: (any ImageFeed.ImagesListViewPresenterProtocol)?
    
    func updateTableViewAnimated(_ oldCount: Int, _ newCount: Int) {
        
    }
    
    func reloadRow(at indexPath: IndexPath) {
        
    }
    
    
}
final class ImageslistViewPresenterSpy: ImagesListViewPresenterProtocol {
    var configureImageListCellCalled = false
    var viewDidLoadCalled = false
    var view: ImagesListViewControllerProtocol?
    var photos: [Photo] = []
    func viewDidLoad(showHUD: Bool) {
        viewDidLoadCalled = true
    }
    func configureImageListCell() {
        configureImageListCellCalled = true
    }
  
    func didTapLike(at indexPath: IndexPath) -> Bool? {
        return nil
    }
    
    func loadImage(for photo: Photo, cell: ImagesListCell, indexPath: IndexPath) {
        
    }
    
  
}
