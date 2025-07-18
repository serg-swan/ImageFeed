//
//  ViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 26.04.2025.
//
import UIKit


final class ImagesListViewController: UIViewController {
    
    // MARK: - @IBOutlet
    
    @IBOutlet private weak var tableView: UITableView!
    
    // MARK: - Private Properties
    private var photos: [Photo] = []
    private let imagesListService = ImagesListService.shared
    private var imagesListServiceObserver: NSObjectProtocol?
    private let showSingleImageSegueIdentifier = "ShowSingleImage"
    private let photosName: [String] = Array(0..<20).map{ "\($0)" }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        setupTableView()
        loadInitialPhotos()
        configureImageListCell()
        
    }
    
    // MARK: Private Methods
    
    private func loadInitialPhotos() {
        guard let token = OAuth2TokenStorage.shared.token else { return }
        UIBlockingProgressHUD.show()
        imagesListService.fetchPhotosNextPage(token) { [weak self] result in
            guard let self = self else { return }
            UIBlockingProgressHUD.dismiss()
            switch result {
            case .success:
                self.updateTableViewAnimated()
            case .failure(let error):
                print("Error loading initial photos: \(error)")
             
            }
        }
    }
    private func configureImageListCell() {
        imagesListServiceObserver = NotificationCenter.default
            .addObserver(forName: ImagesListService.didChangeNotification,
                         object: nil,
                         queue: .main
            ) { [weak self] _ in
                print("Получено уведомление о загрузке таблицы!")
                guard let  self = self  else { return}
                self.updateTableViewAnimated()
            }
        
    }
    
    func updateTableViewAnimated() {
        let oldCount = photos.count
        let newCount = imagesListService.photos.count
        guard newCount > oldCount else { return }
        photos = imagesListService.photos
        tableView.performBatchUpdates {
            let indexPaths = (oldCount..<newCount).map {
                IndexPath(row: $0, section: 0)
            }
            tableView.insertRows(at: indexPaths, with: .automatic)
        } completion: { _ in }
    }
    
    private func setupTableView() {
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
    }
    
    
}

// MARK: - UITableViewDataSource

extension ImagesListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return photos.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt  indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ImagesListCell.reuseIdentifier, for: indexPath)
        guard let imageListCell = cell as? ImagesListCell else {
            return UITableViewCell()
        }
        imageListCell.delegate = self
        let photo = photos[indexPath.row]
        let oldSize = photo.size
        imageListCell.imageCell.kf.indicatorType = .activity
        imageListCell.imageCell.kf.setImage(
            with: URL(string: photo.thumbImageURL),
            placeholder: UIImage(named: "placeholderImageCell"),
            completionHandler: { [weak self] result in
                guard let self = self,
                      case .success(let imageResult) = result,
                      oldSize != imageResult.image.size else { return }
                self.photos[indexPath.row].size = imageResult.image.size
                DispatchQueue.main.async {
                    if let visiblePaths = tableView.indexPathsForVisibleRows,
                       visiblePaths.contains(indexPath) {
                        UIView.performWithoutAnimation {
                            tableView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                }
            }
        )
        if  let date = photo.createdAt {
            imageListCell.dateLabel.text =  DateFormatter.russianMediumDate.string(from: date)
        }
            else {
            imageListCell.dateLabel.text = ""
        }
       
       
        let likeImage = photo.isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
        imageListCell.likeButton.setImage(likeImage, for: .normal)
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
            
            let image =  photos[indexPath.row]
            viewController.imageURL = URL(string: image.largeImageURL)
            
        } else {
            super.prepare(for: segue, sender: sender)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == photos.count - 1 {
            guard let token = OAuth2TokenStorage.shared.token else { return }
            imagesListService.fetchPhotosNextPage(token) {[weak self] result in
                guard let self else { return }
                switch result {
                case .success(_):
                    self.updateTableViewAnimated()
                case .failure(let error):
                    print("Error: \(error)")
                }
                
            }
        }
    }
}
// MARK: - UITableViewDelegate

extension ImagesListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showSingleImageSegueIdentifier, sender: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let image = photos[indexPath.row]
        
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
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let photo = photos[indexPath.row]
        UIBlockingProgressHUD.show()
        guard let token = OAuth2TokenStorage.shared.token else { return }
        imagesListService.changeLike(token, photoId: photo.id, isLike: !photo.isLiked) {[weak self] result in
            DispatchQueue.main.async {
                UIBlockingProgressHUD.dismiss()
                switch result {
                case .success:
                    guard let self else {return}
                    self.photos = self.imagesListService.photos
                    cell.setIsLiked(self.photos[indexPath.row].isLiked)
                case .failure:
                    print("Error")
                    
                }
            }
        }
        
    }
    
}
