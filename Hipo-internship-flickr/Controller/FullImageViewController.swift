//
//  FullImageViewController.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import UIKit
import Kingfisher

class FullImageViewController: UIViewController {
   
    var postImageView:UIImageView?
    var postImageUrl: String?


    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: loadView
    override func loadView() {
        super.loadView()

        view.backgroundColor = .black
        
        // scrollView
        let scrollView = UIScrollView()
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 6.0
        scrollView.delegate = self
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.center = self.view.center
        view.addSubview(scrollView)
        
        // postImageView
        postImageView = UIImageView()
        postImageView!.backgroundColor = .clear
        postImageView?.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 500)
        postImageView?.center = self.view.center
        postImageView?.contentMode = .scaleAspectFit
        self.postImageView!.kf.setImage(with: URL(string: postImageUrl!))
        
        scrollView.addSubview(postImageView!)
        
        // closeButton
        let closeButton = UIButton(frame: CGRect(x: view.frame.width - 60, y: 60, width: 40, height: 40))
        closeButton.setTitle("X", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont(name: "Avenir next", size: 32)
        let gesture = UITapGestureRecognizer(target: self, action: #selector(closeButtonClicked(_:)))
        closeButton.addGestureRecognizer(gesture)
        view.addSubview(closeButton)
        
    }
    
    @objc func closeButtonClicked(_ sender:Any) {
        dismiss(animated: true, completion: nil)
    }

}

// MARK: ScrollViewDelegate
extension FullImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return postImageView
    }
}
