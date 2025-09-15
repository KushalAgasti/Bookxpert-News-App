//
//  ArticlesResponse.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation

struct ArticlesResponse: Codable {
    let status: String
    let totalResults: Int?
    let articles: [ArticleDTO]
}

struct ArticleDTO: Codable {
    let source: SourceDTO?
    let author: String?
    let title: String?
    let description: String?
    let url: String?
    let urlToImage: String?
    let publishedAt: String? // iso date

    struct SourceDTO: Codable {
        let id: String?
        let name: String?
    }
}
