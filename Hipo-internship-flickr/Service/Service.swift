//
//  Service.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import Foundation
import Alamofire

fileprivate enum FlickrMethod:String {
    case recent     = "flickr.photos.getRecent"
    case popular    = "flickr.photos.getPopular"
    case search     = "flickr.photos.search"
}

enum PageStyle {
    case firstPage
    case nextPage
}

public class Service {
    
    public static let shared = Service()
    
    // class instances
    var recentPage = 1
    var searchedPage = 1
    
    // API instances
    fileprivate let _apiKey     = "7dce25e2af4c12bdd385c1e27fbd4ed4"
    fileprivate let _secret     = "b13cab8f423e17ba"
    fileprivate let _token      = "72157711127071691-41d2bcc214d5a426"
    fileprivate let _api_sig    = "8c3fc82da6a4861f6b68c401e0077ed8"
    
    // API URLs
    fileprivate let _scheme     = "https"
    fileprivate let _host       = "api.flickr.com"
    fileprivate let _path       = "/services/rest/"
    
    // MARK: global get request
    /// API general get request function
    private func performGetRequest(
                            fmethod:FlickrMethod,
                            page:Int = 1,
                            parameters: [String:String]?,
                            completion: @escaping (Data) -> Void) {
        var url = URLComponents()
        url.scheme = _scheme
        url.host = _host
        url.path = _path
        url.queryItems = [
            URLQueryItem(name: "method", value: fmethod.rawValue),
            URLQueryItem(name: "api_key", value: _apiKey),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "extras", value: "owner_name,icon_server,date_taken"),
            URLQueryItem(name: "per_page", value: "25"),
            URLQueryItem(name: "page", value: "\(page)")
        ]
        
        if let customParameters = parameters {
            for i in customParameters {
                url.queryItems?.append(URLQueryItem(name: i.key, value: i.value))
            }
        }
        print(url.url!)

        DispatchQueue.main.async {
            Alamofire.request(
                url.url!,
                method: .get
            ).responseJSON { response in
                    guard let data = response.data else { return }
                    print(type(of: data))
                    completion(data)
            }
        }
    }
}


// MARK: - Recent posts
extension Service {
    /// fetches searched posts  from API with first or next page
    func fetchRecentPosts(page: PageStyle,completionHandler: @escaping (_:Photos?) -> Void) {
        
        switch page {
            case .firstPage:
                recentPage = 1
            case .nextPage:
                recentPage += 1
        }
        performGetRequest(fmethod: .recent, page: recentPage, parameters: nil) { data in
                do {
                    let post = try JSONDecoder().decode(Post.self, from: data)
                    completionHandler(post.photos)
                } catch {
                    print(error)
            }
        }
    }
}


// MARK: - Searched posts
extension Service {
    /// fetches searched posts  from API with first or next page
    func fetchSearchedPosts(with word: String, page: PageStyle, completionHandler: @escaping (_: Photos?) -> Void) {
        switch page {
              case .firstPage:
                  searchedPage = 1
              case .nextPage:
                  searchedPage += 1
        }
        performGetRequest(fmethod: .search, page: searchedPage, parameters: ["tags":word]) { data in
            do {
                let post = try JSONDecoder().decode(Post.self, from: data)
                completionHandler(post.photos)
            } catch {
                print(error)
            }
        }
    }
}
