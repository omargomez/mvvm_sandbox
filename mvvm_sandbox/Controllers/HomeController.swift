//
//  HomeController.swift
//  mvvm_sandbox
//
//  Created by Omar Eduardo Gomez Padilla on 6/29/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

protocol TableHandler: UITableViewDataSource, UITableViewDelegate {
}

class HomeHandler: NSObject, TableHandler {
    
    let home: Home
    unowned let navController: UINavigationController
    
    init(_ home: Home, _ aNavController: UINavigationController) {
        self.home = home
        self.navController = aNavController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        home.collections.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HomeCell.id) as? HomeCell else {
            fatalError("No home cell!")
        }
        
        let collection = self.home.collections[indexPath.row]
        
        cell.textLabel?.text = collection.title
        cell.imageView?.image = nil
        
        if let imageUrl = URL(string: collection.thumb) {
            URLSession.shared.doImageTask(fromURL: imageUrl, completion: { (image, error) in
                
                guard let image = image, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.imageView?.image = image
                    cell?.setNeedsLayout()
                }
            })

        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collection = self.home.collections[indexPath.row]
        let controller = UIStoryboard.main.instantiateViewController(identifier: CollectionController.id, creator: { coder in
            CollectionController(coder: coder, forCollectionId: collection.code)
        })
        navController.pushViewController( controller, animated: true)
    }
}

class SearchHandler: NSObject, TableHandler {
    
    let search: Search
    unowned let navController: UINavigationController
    
    init(_ search: Search, _ aNavController: UINavigationController) {
        self.search = search
        self.navController = aNavController
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.search.results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchCell.id) as? SearchCell else {
            fatalError("No search cell!")
        }
        
        let result = search.results[indexPath.row]
        
        cell.textLabel?.text = result.title
        
        let strUrl: String = {
            if result.image.thumb.starts(with: "http") {
                return result.image.thumb
            } else {
                return "https:" + result.image.thumb
            }
        }()
        
        if let imageUrl = URL(string: strUrl) {
            URLSession.shared.doImageTask(fromURL: imageUrl, completion: { (image, error) in
                
                guard let image = image, error == nil else {
                    return
                }
                
                DispatchQueue.main.async {
                    let cell = tableView.cellForRow(at: indexPath)
                    cell?.imageView?.image = image
                    cell?.setNeedsLayout()
                }
            })
            
        }
        

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let result = search.results[indexPath.row]
        let controller = UIStoryboard.main.instantiateViewController(identifier: CollectionController.id, creator: { coder in
            UIViewController()
        })
        navController.pushViewController( controller, animated: true)
    }
}

class HomeController: UIViewController {

    @IBOutlet weak var homeTable: UITableView!
    @IBOutlet weak var homeSearch: UISearchBar!
    
    var data: Home = Home()
    var search: Search?
    
    var currentSearchTask: URLSessionTask?
    var currentHandler: TableHandler?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.homeTable.dataSource = self
        self.homeTable.delegate = self
        self.homeSearch.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadHome()
    }
    
    final func loadHome() {
        URLSession.shared.doDecodeTask(Home.self, from: PPOCEndPoint.home.url) { [weak self] home, error in
            
            guard let homeData = home, error == nil else {
                //                alert(withError: error)// TODO
                return
            }
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                
                self.data = homeData
                self.search = nil
                self.currentHandler = HomeHandler(homeData, self.navigationController!)
                self.homeTable.dataSource = self.currentHandler
                self.homeTable.delegate = self.currentHandler
                self.homeTable.reloadData()
            }
            
        }
    }
}

extension HomeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        UITableViewCell()
    }

}

extension HomeController: UITableViewDelegate {
}

extension HomeController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.currentSearchTask?.cancel()
        
        self.currentSearchTask = URLSession.shared.dataTask(with: PPOCEndPoint.search(query: searchText).url, completionHandler: { (rawData, response, error) in
            
            guard let data = rawData, error == nil else {
                print("Search Error!")
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(Search.self, from: data)
                DispatchQueue.main.async {
                    self.currentSearchTask = nil
                    self.search = decoded
                    self.currentHandler = SearchHandler(decoded, self.navigationController!)
                    self.homeTable.dataSource = self.currentHandler
                    self.homeTable.delegate = self.currentHandler
                    self.homeTable.reloadData()
                }
            } catch {
                // TODO: Error!!!
            }

        })
        
        currentSearchTask?.resume()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // Cancel search mode ...
        self.currentSearchTask?.cancel()
        self.homeSearch.searchTextField.text = ""
        self.homeSearch.resignFirstResponder()

        loadHome()
    }
}
