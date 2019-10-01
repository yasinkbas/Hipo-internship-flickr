//
//  AppDelegate.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow(frame: UIScreen.main.bounds)
        let navigation = UINavigationController()
        let viewController = ViewController()
        navigation.viewControllers = [viewController]
        
        window?.rootViewController = navigation
        window?.makeKeyAndVisible()
        
        return true
    }
    
}

