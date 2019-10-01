//
//  Post.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import Foundation

// MARK: - Post
struct Post: Codable {
    let photos: Photos
    let stat: String
}

// MARK: - Photos
struct Photos: Codable {
    let page, pages, perpage: Int
    let photo: [Photo]
}

// MARK: - Photo
struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
    let datetaken: String
    let ownername, iconserver: String
    let iconfarm: Int
    
    func getPhotoUrl() -> String {
        "https://farm\(farm).staticflickr.com/\(server)/\(id)_\(secret).jpg"
    }
    
    func getProfilePhoto() -> String {
        "https://farm\(farm).staticflickr.com/\(server)/buddyicons/\(owner).jpg"
    }
}
