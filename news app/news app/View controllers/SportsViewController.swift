

//
//  SportsViewController.swift
//  news app
//
//  Created by Agasti.kushal on 12/09/25.
//

import UIKit
import CoreData

class SportsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
        
    @IBOutlet weak var title_label: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    
    private var articles: [Article] = []
    private let viewModel = ArticlesListViewModel()
    private let refreshControl = UIRefreshControl()
    private var filteredArticles: [Article] = []


    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Sports News"
        view.backgroundColor = .systemBackground
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .systemBackground
        tableView.register(NewsTableViewCell.self, forCellReuseIdentifier: "NewsCell")
        
        // Setup refresh control
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.refreshControl = refreshControl
        
        viewModel.onUpdate = { [weak self] in
               DispatchQueue.main.async {
                   guard let self = self else { return }
                   self.articles = self.viewModel.filteredArticles ?? []
                   self.filteredArticles = self.articles // Initially show all articles
                   self.tableView.reloadData()
                   self.refreshControl.endRefreshing()
               }
           }
        
        searchBar.delegate = self

        fetchSportsNews()
        viewModel.refresh()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    @objc private func refreshData() {
        fetchSportsNews()
    }
    
    private func fetchSportsNews() {
        NewsAPIService.shared.fetchTopHeadlines(category: "sports") { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let apiArticles):
                let context = CoreDataStack.shared.viewContext
                context.perform {
                    for dto in apiArticles {
                        _ = Article.createOrUpdate(from: dto, context: context)
                    }
                    CoreDataStack.shared.saveContext()
                    
                    let request: NSFetchRequest<Article> = Article.fetchRequest()
                    if let savedArticles = try? context.fetch(request) {
                        DispatchQueue.main.async {
                            self.articles = savedArticles
                            self.tableView.reloadData()
                            self.refreshControl.endRefreshing() // Stop refreshing after reload
                        }
                    }
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
                print("❌ Error: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredArticles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as? NewsTableViewCell else {
                return UITableViewCell()
            }
            cell.configure(with: filteredArticles[indexPath.row])
            cell.selectionStyle = .none
            return cell
        }

        // MARK: - UITableViewDelegate
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let article = filteredArticles[indexPath.row]
            let detailVC = NewsDetailViewController()
            detailVC.article = article
            if let sheet = detailVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
                sheet.prefersGrabberVisible = true
            }
            present(detailVC, animated: true, completion: nil)
        }

        // MARK: - UISearchBarDelegate
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            print("Search text changed: \(searchText)")
            if searchText.isEmpty {
                filteredArticles = articles
            } else {
                filteredArticles = articles.filter { article in
                    let title = article.title ?? ""
                    let contains = title.lowercased().contains(searchText.lowercased())
                    print("Checking '\(title)': \(contains)")
                    return contains
                }
            }
            tableView.reloadData()
        }

        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
            searchBar.resignFirstResponder()
        }
    }
