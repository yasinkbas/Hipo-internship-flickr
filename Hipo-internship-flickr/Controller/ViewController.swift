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
    lazy var historyTableView = UITableView()
    
    // instances
    var safeArea: UILayoutGuide!
    
    var photos: [Photo]? = nil
    var method: FlickrMethod = .search
    var searchedText: String? = "cats"
    var fetchingMore = false
    var historyArray: [String]? = nil
    
    var service = Service.shared
    var udManager = UserDefaultsManager.shared

//    MARK: - View didLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // baseTableView
        baseTableView.dataSource         = self
        baseTableView.delegate           = self
        baseTableView.estimatedRowHeight = view.bounds.height / 2.5
        baseTableView.separatorStyle     = .none
        
        // historyTableView
        historyTableView.dataSource           = self
        historyTableView.delegate             = self
        historyTableView.isHidden             = true
        
        
        // search bar
        searchBar.searchBarStyle         = UISearchBar.Style.default
        searchBar.placeholder            = " Search..."
        searchBar.sizeToFit()
        searchBar.isTranslucent          = false
        searchBar.backgroundImage        = UIImage()
        searchBar.delegate               = self
        searchBar.showsCancelButton      = true
                
        navigationItem.titleView         = searchBar
        
        refreshControl.addTarget(self, action: #selector(refresh(sender:)), for: UIControl.Event.valueChanged)
        changeRefreshControlTitle(with: "cats")
        baseTableView.addSubview(refreshControl)
        
        getPostsOnStart()
//        udManager.removeHistory() // history can be removed
    }
    
    // MARK: Load View
    override func loadView() {
        super.loadView()
        
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        view.addSubview(baseTableView)
        
        setupBaseTableView()
        setupHistoryTableView()
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
    
    func setupHistoryTableView() {
        view.addSubview(historyTableView)
        
        historyTableView.translatesAutoresizingMaskIntoConstraints = false
        historyTableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        historyTableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        historyTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        historyTableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        
        historyTableView.register(UITableViewCell.self, forCellReuseIdentifier: "historyCell")
        
    }
    
    // MARK: - Posts on start
    func getPostsOnStart() {
//**** used cats posts instead recent posts on start ****//
//        service.fetchRecentPosts(page: .firstPage) { photos in
//            if let photos = photos?.photo {
//                self.photos = photos
//                self.tableView.reloadData()
//            }
//        }
        
        service.fetchSearchedPosts(with: "Cats", page: .firstPage) { photos in
            if let photos = photos?.photo {
                self.photos = photos
                self.baseTableView.reloadData()
            }
        }
    }

    
    // MARK: - Refresh Control Actions
    // refreshControl selector
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
    
}

// MARK: - TableViewDataSource & TableViewDelegate
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
        } else if tableView == historyTableView {
            
            if historyArray != nil {
                historyArray?.append("Clear History")
                return historyArray!.count
            }
            return 0
            
        } else {
            return 0
        }
    }
    
    // MARK: TableView: CellForRow
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == baseTableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as? PostCell,
                  let photos = photos else { return UITableViewCell() }
            cell.selectionStyle = .none
            cell.configureCell(photo: photos[indexPath.row])
            
            return cell
            
        } else if tableView == historyTableView {
            
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell") else { return UITableViewCell() }
            
            if indexPath.row == historyArray!.count - 1 {
                cell.textLabel?.textColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
                cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 16)
                cell.textLabel?.text = historyArray![indexPath.row]
                cell.textLabel?.textAlignment = .center
            } else {
                cell.textLabel?.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
                cell.textLabel?.font = UIFont.systemFont(ofSize: 18)
                cell.textLabel?.text = historyArray![indexPath.row]
                cell.textLabel?.textAlignment = .left
            }
            
            return cell
            
        } else {
            return UITableViewCell()
        }
       
    }
    
    // MARK: TableView: didSelect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == baseTableView {
        
            let vc = FullImageViewController()
            vc.postImageUrl = photos![indexPath.row].getPhotoUrl()
            vc.modalPresentationStyle = .fullScreen
            vc.modalTransitionStyle = .crossDissolve
            present(vc,animated: true,completion: nil)
            
        } else if tableView == historyTableView {
            if indexPath.row == historyArray!.count - 1 {
                udManager.removeHistory()
                historyTableView.isHidden = true
                searchBar.text = ""
                searchBar.endEditing(true)
            }
            else {
                searchBar.text = historyArray![indexPath.row]
            }
            
        }
    }
    
    // MARK:- Infinite Scroll Tableview
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        
        if offsetY > contentHeight - scrollView.frame.height {
            if !fetchingMore {
                beginBatchFetch()
            }
        }
    }
    
    func beginBatchFetch() {
        fetchingMore = true
        
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
                    if let photosData = photos,let _ = self.photos {
                        self.photos! += photosData.photo
                        self.baseTableView.reloadData()
                    }
                }
            }
           
            self.fetchingMore = false
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
        historyTableView.isHidden = true
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
            self.historyTableView.isHidden = true
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        historyArray = udManager.getHistory()?.reversed()
        historyTableView.reloadData()
        historyTableView.isHidden = historyArray == nil // if history is nil don't show history tableview
        return true
    }

}

