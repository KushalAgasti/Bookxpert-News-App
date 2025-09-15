//
//  CoreDataStack.swift
//  news app
//
//  Created by Agasti.kushal on 13/09/25.
//

import Foundation
import CoreData

final class CoreDataStack {
    static let shared = CoreDataStack()
    private init() {}

    lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Article") // ensure model file name
        container.loadPersistentStores { desc, error in
            if let e = error {
                fatalError("CoreData load error: \(e)")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        return container
    }()

    var viewContext: NSManagedObjectContext { container.viewContext }

    func saveContext() {
        let ctx = viewContext
        if ctx.hasChanges {
            do { try ctx.save() }
            catch { print("CoreData save error:", error) }
        }
    }
}
