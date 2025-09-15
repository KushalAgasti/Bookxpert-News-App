//
//  ArticleRepository.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation
import CoreData

final class ArticleRepository {
    private let network = NewsAPIService.shared
    private let coreData = CoreDataStack.shared

    // Fetch from network and update core data
    func refreshFromNetwork(completion: @escaping (Result<[Article], Error>) -> Void) {
        network.fetchTopHeadlines { result in
            switch result {
            case .failure(let nerr):
                DispatchQueue.main.async { completion(.failure(nerr)) }
            case .success(let dtos):
                let ctx = self.coreData.container.newBackgroundContext()
                ctx.perform {
                    var saved: [Article] = []
                    for dto in dtos {
                        let art = Article.createOrUpdate(from: dto, context: ctx)
                        saved.append(art)
                    }
                    do {
                        try ctx.save()
                        // fetch saved objects in viewContext to return
                        let mainCtx = self.coreData.viewContext
                        let ids = saved.compactMap { $0.id ?? "" }
                        let req: NSFetchRequest<Article> = Article.fetchRequest()
                        req.predicate = NSPredicate(format: "id IN %@", ids)
                        let fetched = try mainCtx.fetch(req)
                        DispatchQueue.main.async { completion(.success(fetched)) }
                    } catch {
                        DispatchQueue.main.async { completion(.failure(error)) }
                    }
                }
            }
        }
    }

    // Fetch cached articles from Core Data
    func fetchCachedArticles(predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor]? = nil) -> [Article] {
        let req: NSFetchRequest<Article> = Article.fetchRequest()
        req.predicate = predicate
        req.sortDescriptors = sortDescriptors ?? [NSSortDescriptor(key: "publishedAt", ascending: false)]
        return (try? coreData.viewContext.fetch(req)) ?? []
    }

    func toggleBookmark(_ article: Article) {
        let ctx = coreData.viewContext
        article.isBookmarked.toggle()
        coreData.saveContext()
    }
}

