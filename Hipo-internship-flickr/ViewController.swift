//
//  ViewController.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // Components
    lazy var tableView = UITableView()
    lazy var searchBar:UISearchBar = UISearchBar()
    
    // instances
    var safeArea: UILayoutGuide!
    
    var photos: [Photo]? = nil
    var method: FlickrMethod = .recent
    var searchedText: String?
    var fetchingMore = false
    
    var service = Service.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview
        tableView.dataSource            = self
        tableView.delegate              = self
        tableView.estimatedRowHeight    = view.bounds.height / 2.5
        tableView.separatorStyle        = .none
        
        // search bar
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        
        // remove x button from searchbar because we already use cancel button
        let searchBarStyle = searchBar.value(forKey: "searchField") as? UITextField
        searchBarStyle?.clearButtonMode = .never
        
        navigationItem.titleView = searchBar
        
        service.fetchRecentPosts(page: .firstPage) { photos in
            if let photos = photos?.photo {
                self.photos = photos
                print(photos)
                self.tableView.reloadData()
            }
        }
    }
    
    override func loadView() {
        super.loadView()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        view.addSubview(tableView)
        setupTableView()
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        tableView.register(PostCell.self, forCellReuseIdentifier: "cell")
    }

}
// MARK: - TableViewDataSource&TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height / 2.5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        photos?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PostCell,
              let photos = photos else { return UITableViewCell() }
        cell.configureCell(photo: photos[indexPath.row])
        
        return cell 
    }
    
    // MARK:- Infinite Scroll Tableview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        print("offsetY: \(offsetY), totalHeight: \(contentHeight)")
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        print("fetch is started")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            switch self.method {
                
            case .recent:
                self.service.fetchRecentPosts(page: .nextPage) { photos in
                   if let photos = photos {
                       self.photos! += photos.photo
                       self.tableView.reloadData()
                       print(self.photos)
                   }
               }
                
            case .search:
                self.service.fetchSearchedPosts(with: self.searchedText ?? "", page: .nextPage) { photos in
                    if let photos = photos {
                        self.photos! += photos.photo
                        self.tableView.reloadData()
                        print(self.photos)
                    }
                }
            }
           
            self.fetchingMore = false
            print("fetch is ended")
        }
    }
}

// MARK:- SearchBarDelegate
extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // show cancel button if not empty
        if let text = searchBar.text {
            searchBar.showsCancelButton = text == "" ? false : true
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        // clear the text in the search bar
        searchBar.text = ""
        // hideCancel button
        searchBar.showsCancelButton = false
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.method = .search
        guard let text = searchBar.text else { return }
        self.searchedText = text
        service.fetchSearchedPosts(with: text, page: .firstPage) { photos in
            guard let photos = photos else { return }
            self.photos = photos.photo
            self.searchBar.endEditing(true)
            self.tableView.reloadData()
            
        }
    }
}

