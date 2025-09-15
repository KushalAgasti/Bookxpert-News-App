//
//  NewsDetailViewController.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation
import UIKit

class NewsDetailViewController: UIViewController {
    var article: Article?
    
    private let titleLabel = UILabel()
    private let imageView = UIImageView()
    private let descriptionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        
        if let article = article {
            titleLabel.text = article.title
            descriptionLabel.text = article.summary
            if let urlString = article.imageUrl, let url = URL(string: urlString) {
                loadImage(from: url)
            }
        }
    }
    
    private func setupUI() {
        titleLabel.font = .boldSystemFont(ofSize: 18)
        titleLabel.numberOfLines = 0
        
        descriptionLabel.font = .systemFont(ofSize: 14)
        descriptionLabel.numberOfLines = 0
        
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        let stack = UIStackView(arrangedSubviews: [titleLabel, imageView, descriptionLabel])
        stack.axis = .vertical
        stack.spacing = 12
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            imageView.heightAnchor.constraint(equalToConstant: 200)
        ])
    }
    
    private func loadImage(from url: URL) {
        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data, let image = UIImage(data: data) else { return }
            DispatchQueue.main.async { self.imageView.image = image }
        }.resume()
    }
}
