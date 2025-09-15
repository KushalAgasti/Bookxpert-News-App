//
//  NewsTableViewCell.swift
//  news app
//
//  Created by Agasti.kushal on 12/09/25.
//

import UIKit

class NewsTableViewCell: UITableViewCell {
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let thumbnailImageView = UIImageView()
    private let subtitleLabel = UILabel()
    
    @IBOutlet weak var background_View: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        // Initialization code
        
    }
    



    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
           super.init(style: style, reuseIdentifier: reuseIdentifier)

           titleLabel.font = .boldSystemFont(ofSize: 12)
           titleLabel.numberOfLines = 0
           titleLabel.textColor = .label

           subtitleLabel.font = .systemFont(ofSize: 8)
           subtitleLabel.textColor = .secondaryLabel
           subtitleLabel.numberOfLines = 0

           thumbnailImageView.contentMode = .scaleAspectFill
           thumbnailImageView.clipsToBounds = true

           let stack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
           stack.axis = .vertical
           stack.spacing = 8
           stack.translatesAutoresizingMaskIntoConstraints = false

           contentView.addSubview(thumbnailImageView)
           contentView.addSubview(stack)

           thumbnailImageView.translatesAutoresizingMaskIntoConstraints = false

           NSLayoutConstraint.activate([
               thumbnailImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
               thumbnailImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
               thumbnailImageView.widthAnchor.constraint(equalToConstant: 100),
               thumbnailImageView.heightAnchor.constraint(equalToConstant: 70),

               stack.leadingAnchor.constraint(equalTo: thumbnailImageView.trailingAnchor, constant: 12),
               stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
               stack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
               stack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
           ])
       }

       required init?(coder: NSCoder) {
           fatalError("init(coder:) has not been implemented")
       }

     

       override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
       }

       func configure(with article: Article) {
           titleLabel.text = article.title ?? "No Title"
           subtitleLabel.text = article.summary ?? "No Description"

           if let urlString = article.imageUrl,
              let url = URL(string: urlString) {
               URLSession.shared.dataTask(with: url) { data, _, _ in
                   if let data = data {
                       DispatchQueue.main.async {
                           self.thumbnailImageView.image = UIImage(data: data)
                       }
                   }
               }.resume()
           } else {
               thumbnailImageView.image = UIImage(systemName: "photo")
           }

           let isDark = traitCollection.userInterfaceStyle == .dark
           contentView.backgroundColor = isDark ? .black : .white
           titleLabel.textColor = isDark ? .white : .black
           subtitleLabel.textColor = isDark ? .lightGray : .darkGray
       }
   }
