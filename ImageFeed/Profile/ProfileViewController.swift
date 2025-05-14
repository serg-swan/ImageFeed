//
//  ProfileViewController.swift
//  ImageFeed
//
//  Created by Сергей Лебедь on 02.05.2025.
//
import UIKit
import Foundation

final class ProfileViewController: UIViewController {
    
    // MARK: - Private Properties
    
    private let imageView = UIImageView()
    private let nameLabel = UILabel()
    private let loginLabel = UILabel()
    private let descriptionLabel = UILabel()
    private  let button = UIButton(type: .custom)
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageVievUI()
        setupNameLabelUI()
        setupLoginUI()
        setupDescriptionLabelUI()
        setupButtonUI()
        addSubview()
        setupConstraint()
        
    }
    
    // MARK: - Private Methods
    
    private func setupImageVievUI() {
        
        guard let profileImage = UIImage(named: "Avatar") else {  fatalError("Изображение Avatar не найдено в Assets.xcassets") }
        let imageView = self.imageView
        imageView.image = profileImage
        imageView.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupNameLabelUI() {
        
        let nameLabel = self.nameLabel
        nameLabel.text = "Екатерина Новикова"
        nameLabel.font = .boldSystemFont(ofSize: 23)
        nameLabel.textColor = UIColor(named: "YP White (iOS)") ?? .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupLoginUI() {
        let loginLabel = self.loginLabel
        loginLabel.text = "@ekaterina_nov"
        loginLabel.font = .systemFont(ofSize: 13)
        loginLabel.textColor = UIColor(named: "YP Gray (iOS)") ?? .gray
        loginLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    private func setupDescriptionLabelUI() {
        let descriptionLabel = self.descriptionLabel
        descriptionLabel.text = "Hello, world!"
        descriptionLabel.font = .systemFont(ofSize: 13)
        descriptionLabel.textColor = UIColor(named: "YP White (iOS)") ?? .white
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    private func setupButtonUI() {
        guard let buttonImage = UIImage(named: "OutButton") else {
            fatalError("Изображение OutButton не найдено в Assets.xcassets")
        }
        let button = self.button
        button.setImage(buttonImage, for: .normal)
        button.addTarget(
            self,
            action: #selector(didTapButton),
            for: .touchUpInside
        )
        button.translatesAutoresizingMaskIntoConstraints = false
    }
    private func addSubview() {
        view.addSubview(imageView)
        view.addSubview(nameLabel)
        view.addSubview(loginLabel)
        view.addSubview(descriptionLabel)
        view.addSubview(button)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 16),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 32),
            imageView.widthAnchor.constraint(equalToConstant: 70),
            imageView.heightAnchor.constraint(equalToConstant: 70),
            nameLabel.leadingAnchor.constraint(equalTo: imageView.leadingAnchor),
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 8),
            loginLabel.leadingAnchor.constraint(equalTo:  nameLabel.leadingAnchor),
            loginLabel.topAnchor.constraint(equalTo:  nameLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo:  loginLabel.leadingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo:  loginLabel.bottomAnchor, constant: 8),
            button.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 44),
            button.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    @objc
    private func didTapButton() {
        
    }
    
}
