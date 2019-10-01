//
//  ViewController.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    lazy var tableView = UITableView()
    var safeArea: UILayoutGuide!
    
    var photos: [Photo]? = nil
    var method: FlickrMethod = .recent

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // tableview
        tableView.dataSource            = self
        tableView.delegate              = self
        tableView.estimatedRowHeight    = view.bounds.height / 2.5
        tableView.separatorStyle        = .none
        
        Service.shared.fetchRecentPosts(page: .firstPage) { photos in
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
        
        return cell ?? UITableViewCell()
    }
}

