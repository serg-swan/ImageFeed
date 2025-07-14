//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 26.04.2025.
//
import UIKit

protocol ImagesListViewControllerProtocol: AnyObject {
    var presenter: ImagesListViewPresenterProtocol? { get set }
    func updateTableViewAnimated(_ oldCount: Int ,_ newCount: Int)
    func reloadRow(at indexPath: IndexPath)
}

final class ImagesListViewController: UIViewController, ImagesListViewControllerProtocol{
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var tableView: UITableView!
    // MARK: - Public Properties
    var presenter: ImagesListViewPresenterProtocol?
    
    // MARK: - Private Properties
    
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setupTableView()
        presenter?.configureImageListCell()
        presenter?.viewDidLoad(showHUD: true)
    }
    
    // MARK: Public Methods
    
    func configure(_ presenter: ImagesListViewPresenterProtocol) {
        self.presenter = presenter
        self.presenter?.view = self
    }
    
    func updateTableViewAnimated(_ oldCount: Int ,_ newCount: Int) {
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    func reloadRow(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            if let visiblePaths = self.tableView.indexPathsForVisibleRows,
               visiblePaths.contains(indexPath) {
                UIView.performWithoutAnimation {
                    self.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return presenter?.photos.count ?? 0
    }
    func tableView(_ tableView: UITableView, cellForRowAt  indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell,
              let photo = presenter?.photos[indexPath.row] else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        
        presenter?.loadImage(for: photo, cell: imageListCell, indexPath: indexPath)
        return imageListCell
        
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showSingleImageSegueIdentifier {
            guard
                let viewController = segue.destination as? SingleImageViewController,
                let indexPath = sender as? IndexPath
            else {
                assertionFailure("Invalid segue destination")
                return
            }
            
            guard let image =  presenter?.photos[indexPath.row] else { return }
            viewController.imageURL = URL(string: image.largeImageURL)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == (presenter?.photos.count ?? 0) - 1 {
            presenter?.viewDidLoad(showHUD: false)
        }
    }
}
// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard  let image = presenter?.photos[indexPath.row] else { return 0 }
        
        let imageInsets = UIEdgeInsets(top: 4, left: 16, bottom: 4, right: 16)
        let imageViewWidth = tableView.bounds.width - imageInsets.left - imageInsets.right
        let imageWidth = image.size.width
        let scale = imageViewWidth / imageWidth
        let cellHeight = image.size.height * scale + imageInsets.top + imageInsets.bottom
        return cellHeight
    }
}

extension ImagesListViewController: ImagesListCellDelegate {
    func imageListCellDidTapLike(_ cell: ImagesListCell) {
        guard let indexPath = tableView.indexPath(for: cell),
              let newStatus = presenter?.didTapLike(at: indexPath) else { return }
        cell.setIsLiked(newStatus)
    }
    
}
