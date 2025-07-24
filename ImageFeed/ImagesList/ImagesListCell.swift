//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 01.05.2025.
//
import UIKit
import Kingfisher


protocol ImagesListCellDelegate: AnyObject {
    func imageListCellDidTapLike(_ cell: ImagesListCell)
}

final class ImagesListCell: UITableViewCell {
    
    static let reuseIdentifier = "ImagesListCell"
    var currentImageURL: String?
    
    weak var delegate: ImagesListCellDelegate?
    
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBAction private func didTapButton(_ sender: Any) {
        delegate?.imageListCellDidTapLike(self)
       
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        imageCell.kf.cancelDownloadTask()
        imageCell.image = UIImage(named: "placeholderImageCell")
        currentImageURL = nil
      
    }
    func setIsLiked (_ isLiked: Bool) {
        DispatchQueue.main.async {
            let image = isLiked ? UIImage(named: "like_button_on") : UIImage(named: "like_button_off")
            self.likeButton.setImage(image, for: .normal)
            self.likeButton.accessibilityIdentifier = isLiked ? "like_button_on" : "like_button_off"
        }
    }
}
