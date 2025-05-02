//
//  ImagesListCell.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 01.05.2025.
//
import UIKit


final class ImagesListCell: UITableViewCell {
    static let reuseIdentifier = "ImagesListCell"
    @IBOutlet weak var imageCell: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
   
}
