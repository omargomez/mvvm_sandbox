//
//  CollectionController.swift
//  mvvm_sandbox
//
//  Created by Omar Eduardo Gomez Padilla on 6/29/20.
//  Copyright © 2020 Omar Eduardo Gomez Padilla. All rights reserved.
//

import UIKit

class CollectionController: UIViewController {

    static let id = "\(CollectionController.self)"
    
    @IBOutlet weak var pageStatusItem: UIBarButtonItem!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    let collectionId: String
    var currPage: Search.Page?
    
    typealias ItemType = Search.Result
    typealias DatasourceType = UICollectionViewDiffableDataSource<Int, ItemType>
    typealias SnapshotType = NSDiffableDataSourceSnapshot<Int, ItemType>
    
    lazy var datasource: DatasourceType = {
        DatasourceType(collectionView: self.collectionView, cellProvider: { [weak self] (collectionView, indexPath, item) -> UICollectionViewCell? in
            self?.provideCell(indexPath: indexPath, item: item)
        })
    }()
    
    private func provideCell(indexPath: IndexPath, item: ItemType) -> UICollectionViewCell? {
        guard let cell = self.collectionView.dequeueReusableCell(withReuseIdentifier: CollectionCell.id, for: indexPath) as? CollectionCell else {
            fatalError("No collection cell")
        }
        
        cell.image.image = nil
        
        let urlString = "https:" + item.image.square
       
        if let url = URL(string: urlString) {
            cell.scheduleImageLoad(url)
        }

        return cell
    }
    
    lazy var layout: UICollectionViewCompositionalLayout = {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)
        
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(44))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        
        return UICollectionViewCompositionalLayout(section: section)
    }()
    
    func snapshot(for data: [ItemType]) -> SnapshotType {
        var result = SnapshotType()
        result.appendSections([0])
        result.appendItems(data)
        return result
    }
    
    init?(coder: NSCoder, forCollectionId: String) {
        self.collectionId = forCollectionId
        super.init(coder: coder)
    }
    
    required init?(coder aDecoder: NSCoder) {
//        super.init(coder: aDecoder)
        fatalError("This shouldn't be called")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.collectionViewLayout = layout
        datasource.apply(snapshot(for: []))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        doSearch(1)
    }
    
    @IBAction func onBackwardAction(_ sender: Any) {
        guard let page = self.currPage, page.current - 1 >= 1 else { return }
        doSearch(page.current - 1)
    }
    
    @IBAction func onForwardAction(_ sender: Any) {
        // Go to next page...
        guard let page = self.currPage, page.current + 1 <= page.total else { return }
        doSearch(page.current + 1)
    }
    
    private func doSearch(_ page: Int) {
        
        URLSession.shared.doDecodeTask(Search.self, from: PPOCEndPoint.search(query: nil, style: "grid", collectionCode: self.collectionId, startPage: page).url, completion: { [weak self] data, error in
            
            guard let self = self, let searchData = data, error == nil else {
                print("Errror loading collection data")
                return
            }
            
            DispatchQueue.main.async {
                self.currPage = searchData.pages
                self.pageStatusItem.title = "Page (\(searchData.pages.current)/\(searchData.pages.total))"
                self.datasource.apply(self.snapshot(for: searchData.results))
                self.navigationItem.title = searchData.collection.title
            }
        })

    }
}
