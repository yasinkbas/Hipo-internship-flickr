//
//  UserDefaultsManager.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    static let shared = UserDefaultsManager()
    
    let ud = UserDefaults.standard
    
    func getHistory() -> [String]? {
        let history = ud.array(forKey: "history")
        return history as? [String]
    }
    
    func addHistory(text:String) {
        var array = [String]()
        if let histories = ud.array(forKey: "history") as? [String] {
            array = histories
            array.append(text)
        } else {
            array.append(text)
        }
        
        ud.set(array, forKey: "history")
    }
    
    func removeHistory() {
        ud.removeObject(forKey: "history")
    }
}
