//
//  NewsAPIService.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation

final class NewsAPIService {
    static let shared = NewsAPIService()
    private init() {}

    enum NewsError: Error {
        case transport(Error)
        case server(Int)
        case decoding(Error)
        case unknown
    }

    // fetch top headlines example
    func fetchTopHeadlines(completion: @escaping (Result<[ArticleDTO], NewsError>) -> Void) {
        var components = URLComponents(string: Constants.newsAPIBaseURL)!
        components.queryItems = [
            URLQueryItem(name: "country", value: Constants.country),
            URLQueryItem(name: "apiKey", value: Constants.apiKey)
        ]
        guard let url = components.url else {
            completion(.failure(.unknown)); return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let e = error { completion(.failure(.transport(e))); return }
            if let http = response as? HTTPURLResponse, !(200...299).contains(http.statusCode) {
                completion(.failure(.server(http.statusCode))); return
            }
            guard let data = data else { completion(.failure(.unknown)); return }
            do {
                let decoded = try JSONDecoder().decode(ArticlesResponse.self, from: data)
                completion(.success(decoded.articles))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }
        task.resume()
    }
    
    func fetchTopHeadlines(category: String, completion: @escaping (Result<[ArticleDTO], NewsError>) -> Void) {
        let urlString = "https://newsapi.org/v2/top-headlines?category=\(category)&country=us&apiKey=\(Constants.apiKey)"
        
        guard let url = URL(string: urlString) else {
            completion(.failure(.unknown))
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let e = error {
                completion(.failure(.transport(e)))
                return
            }
            
            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {
                completion(.failure(.server(http.statusCode)))
                return
            }
            
            guard let data = data else {
                completion(.failure(.unknown))
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(ArticlesResponse.self, from: data)
                completion(.success(decoded.articles))
            } catch {
                completion(.failure(.decoding(error)))
            }
        }.resume()
    }
}

//struct NewsResponse: Codable {
//    let articles: [ArticleDTO]
//}
//
//struct ArticleDTO: Codable {
//    let title: String
//    let description: String?
//    let urlToImage: String?
//}
