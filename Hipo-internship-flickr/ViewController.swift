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
    lazy var baseTableView = UITableView()
    lazy var searchBar:UISearchBar = UISearchBar()
    lazy var refreshControl = UIRefreshControl()
    lazy var proposition = UITableView()
    
    // instances
    var safeArea: UILayoutGuide!
    
    var photos: [Photo]? = nil
    var method: FlickrMethod = .recent
    var searchedText: String? = "cats"
    var fetchingMore = false
    var propositionArray: [String]? = nil
    
    var service = Service.shared
    var udManager = UserDefaultsManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // base table view
        baseTableView.dataSource            = self
        baseTableView.delegate              = self
        baseTableView.estimatedRowHeight    = view.bounds.height / 2.5
        baseTableView.separatorStyle        = .none
        
        // proposition
        proposition.dataSource              = self
        proposition.delegate                = self
        proposition.isHidden                = true
        
        
        // search bar
        searchBar.searchBarStyle = UISearchBar.Style.default
        searchBar.placeholder = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent = false
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        searchBar.showsCancelButton = true
                
        navigationItem.titleView = searchBar
        
        changeRefreshControlTitle(with: "cats")
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        baseTableView.addSubview(refreshControl)
        
        getPostsOnStart()
        udManager.removeHistory()
    }
    
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        view.addSubview(baseTableView)
        
        setupBaseTableView()
        setupProposition()
    }
    
    func setupBaseTableView() {
        view.addSubview(baseTableView)
        
        baseTableView.translatesAutoresizingMaskIntoConstraints = false
        baseTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        baseTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        baseTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        baseTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        baseTableView.register(PostCell.self, forCellReuseIdentifier: "cell")
    }
    
    func setupProposition() {
        view.addSubview(proposition)
        
        proposition.translatesAutoresizingMaskIntoConstraints = false
        proposition.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        proposition.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        proposition.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        proposition.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        proposition.register(UITableViewCell.self, forCellReuseIdentifier: "propositionCell")
        
    }
    
    @objc func refresh(sender:AnyObject) {
        self.refreshControl.endRefreshing()
        
        if let searched = searchedText {
            service.fetchSearchedPosts(with: searched, page: .firstPage) { photos in
                guard let photos = photos?.photo else { return }
                self.photos = photos
            }
        } else {
            getPostsOnStart()
        }
    }
    
    func changeRefreshControlTitle(with text:String) {
        refreshControl.attributedTitle = NSAttributedString(string: searchedText == nil ? "recent" : searchedText!)
    }
    
    func getPostsOnStart() {
        // Disabled recent posts
//        service.fetchRecentPosts(page: .firstPage) { photos in
//            if let photos = photos?.photo {
//                self.photos = photos
//                print(photos)
//                self.tableView.reloadData()
//            }
//        }
        service.fetchSearchedPosts(with: "Cats", page: .firstPage) { photos in
            if let photos = photos?.photo {
                self.photos = photos
                print(photos)
                self.baseTableView.reloadData()
            }
        }
    }
    


}
// MARK: - TableViewDataSource&TableViewDelegate
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == baseTableView {
            return view.bounds.height / 2.5
        } else {
            return 44
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == baseTableView {
            return photos?.count ?? 0
        } else if tableView == proposition {
            return propositionArray?.count ?? 0
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if tableView == baseTableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PostCell,
                  let photos = photos else { return UITableViewCell() }
            cell.configureCell(photo: photos[indexPath.row])
            
            return cell
        } else if tableView == proposition {
            print(1)
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "propositionCell") else { return UITableViewCell() }
            cell.textLabel?.text = propositionArray![indexPath.row]
            print(propositionArray![indexPath.row])
            
            return cell
        } else {
            return UITableViewCell()
        }
       
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == baseTableView {
            
        } else if tableView == proposition {
            searchBar.text = propositionArray![indexPath.row]
        }
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
                        self.baseTableView.reloadData()
                   }
               }
                
            case .search:
                self.service.fetchSearchedPosts(with: self.searchedText ?? "", page: .nextPage) { photos in
                    if let photos = photos {
                        self.photos! += photos.photo
                        self.baseTableView.reloadData()
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
        searchBar.showsCancelButton = true // showed cancel button for using dissmiss keyboard
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        proposition.isHidden = true
        searchBar.endEditing(true)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.method = .search
        guard let text = searchBar.text else { return }
        self.searchedText = text
        service.fetchSearchedPosts(with: text, page: .firstPage) { photos in
            guard let photos = photos else { return }
            self.photos = photos.photo
            self.searchBar.endEditing(true)
            self.baseTableView.reloadData()
            self.changeRefreshControlTitle(with: text)
            self.udManager.addHistory(text: text)
            self.proposition.isHidden = true
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        propositionArray = udManager.getHistory()?.reversed()
        proposition.reloadData()
        proposition.isHidden = propositionArray == nil // if history is nil don't show proposition tableview
        return true
    }

}

