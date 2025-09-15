//
//  ArticlesListViewModel.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation
import CoreData

class ArticlesListViewModel {
    private let repository = ArticleRepository()
    private(set) var allArticles: [Article] = []
    private(set) var filteredArticles: [Article] = []

    // binding closures
    var onUpdate: (() -> Void)?
    var onError: ((String) -> Void)?

    // Search text
    var searchText: String = "" {
        didSet { applyFilter() }
    }

    func loadCachedArticles() {
        allArticles = repository.fetchCachedArticles()
        applyFilter()
    }

    func refresh() {
        repository.refreshFromNetwork { [weak self] result in
            switch result {
            case .failure(let err):
                self?.onError?(err.localizedDescription)
                // still show cached
                self?.loadCachedArticles()
            case .success:
                self?.loadCachedArticles()
            }
        }
    }

    func applyFilter() {
        if searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filteredArticles = allArticles
        } else {
            let q = searchText.lowercased()
            filteredArticles = allArticles.filter { ( $0.title ?? "" ).lowercased().contains(q) }
        }
        onUpdate?()
    }

    func toggleBookmark(article: Article) {
        repository.toggleBookmark(article)
        loadCachedArticles()
    }

    func bookmarkedArticles() -> [Article] {
        repository.fetchCachedArticles(predicate: NSPredicate(format: "isBookmarked == YES"))
    }
}

//extension Article {
//    @nonobjc public class func fetchRequest() -> NSFetchRequest<Article> {
//        NSFetchRequest<Article>(entityName: "Article")
//    }
//
//    @NSManaged public var id: String?
//    @NSManaged public var title: String?
//    @NSManaged public var author: String?
//    @NSManaged public var summary: String?
//    @NSManaged public var url: String?
//    @NSManaged public var imageUrl: String?
//    @NSManaged public var publishedAt: Date?
//    @NSManaged public var isBookmarked: Bool
//    @NSManaged public var rawJSON: Data?
//}

extension Article {
    static func createOrUpdate(from dto: ArticleDTO, context: NSManagedObjectContext) -> Article {
        // use url or title as unique id (news apis often don't provide id)
        let id = dto.url ?? UUID().uuidString

        let request: NSFetchRequest<Article> = Article.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as NSString)
        request.fetchLimit = 1

        let article: Article
        if let existing = (try? context.fetch(request))?.first {
            article = existing
        } else {
            article = Article(context: context)
            article.id = id
        }

        article.title = dto.title
        article.author = dto.author
        article.summary = dto.description
        article.url = dto.url
        article.imageUrl = dto.urlToImage
        if let published = dto.publishedAt {
            // parse ISO date
            let formatter = ISO8601DateFormatter()
            article.publishedAt = formatter.date(from: published)
        }

        // store raw JSON optionally
        if let data = try? JSONEncoder().encode(dto) { article.rawJSON = data }

        return article
    }
}
