//
//  SingleImageViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 04.05.2025.
//

import Foundation
import UIKit
import Kingfisher
final class SingleImageViewController: UIViewController {
    
    // MARK: - Public Properties
    
    var imageURL: URL? {
          didSet {
              guard isViewLoaded else { return }
              loadImage()
          }
      }
    
       var image: UIImage? {
        didSet {
            guard isViewLoaded, let image else { return }
           updateUI(with: image)
        scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    // MARK: - IBOutlets
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var scrollView: UIScrollView!
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.minimumZoomScale = 0.1
        scrollView.maximumZoomScale = 1.25
        guard let image else {
            return loadImage() }
     updateUI(with: image)
        
    }
    
    // MARK: - Private Methods
    
    private func loadImage() {
           guard let imageURL = imageURL else { return }
        UIBlockingProgressHUD.show()
           imageView.kf.indicatorType = .activity
           imageView.kf.setImage(
               with: imageURL,
               placeholder: UIImage(named: "placeholderImageCell"),
               options: [.transition(.fade(0.3))], completionHandler: { [weak self] result in
                   guard let self = self else { return }
                   UIBlockingProgressHUD.dismiss()
                   switch result {
                   case .success(let value):
                       self.updateUI(with: value.image)
                   case .failure(let error):
                       self.showError()
                       print("Error loading image: \(error)")
                     
                   }
               }
           
           )
       }
    private func updateUI(with image: UIImage) {
          imageView.image = image
          imageView.frame.size = image.size
          rescaleAndCenterImageInScrollView(image: image)
      }
    
    private func rescaleAndCenterImageInScrollView(image: UIImage) {
        let minZoomScale = scrollView.minimumZoomScale
        let maxZoomScale = scrollView.maximumZoomScale
        view.layoutIfNeeded()
        let visibleRectSize = scrollView.bounds.size
        guard image.size != .zero else { return }
        let imageSize = image.size
        let hScale = visibleRectSize.width / imageSize.width
        let vScale = visibleRectSize.height / imageSize.height
        let scale = min(maxZoomScale, max(minZoomScale, min(hScale, vScale)))
        scrollView.setZoomScale(scale, animated: false)
        scrollView.layoutIfNeeded()
        let newContentSize = scrollView.contentSize
        let x = (newContentSize.width - visibleRectSize.width) / 2
        let y = (newContentSize.height - visibleRectSize.height) / 2
        scrollView.setContentOffset(CGPoint(x: x, y: y), animated: false)
    }
    
    private func centerImageInScrollView() {
        guard let image = imageView.image else { return }
        let imageSize = image.size

        let scaledImageWidth = imageSize.width * scrollView.zoomScale
        let scaledImageHeight = imageSize.height * scrollView.zoomScale
        
        let horizontalInset = max(0, (scrollView.bounds.width - scaledImageWidth) / 2)
        let verticalInset = max(0, (scrollView.bounds.height - scaledImageHeight) / 2)
        
        scrollView.contentInset = UIEdgeInsets(
            top: verticalInset,
            left: horizontalInset,
            bottom: verticalInset,
            right: horizontalInset
        )
    }
    
    private  func showError() {
        let alert = UIAlertController(title: "Что-то пошло не так",
                                      message: "Попробовать еще раз?",
                                      preferredStyle: .alert)
       
          alert.addAction(
              UIAlertAction(
                  title: "Не надо",
                  style: .cancel,
                  handler: nil
              )
          )
          
          alert.addAction(
              UIAlertAction(
                  title: "Повторить",
                  style: .default,
                  handler: { _ in
                      self.loadImage()
                  }
                  )
              )
        present(alert, animated: true)
    }
    
    // MARK: - IBActions
    
    @IBAction func didTapShareButton(_ sender: UIButton) {
        guard let image else { return }
        let share = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        share.overrideUserInterfaceStyle = .dark
        present(share, animated: true, completion: nil)
    }
    
    @IBAction private func didTapBackBatton() {
        dismiss(animated: true, completion: nil)
    }
        
}

extension SingleImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        centerImageInScrollView()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        centerImageInScrollView()
    }
}


