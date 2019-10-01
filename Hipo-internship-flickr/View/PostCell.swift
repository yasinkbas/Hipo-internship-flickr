//
//  PostCell.swift
//  Hipo-internship-flickr
//
//  Created by Yasin Akbaş on 1.10.2019.
//  Copyright © 2019 Yasin Akbaş. All rights reserved.
//

import UIKit


class PostCell: UITableViewCell {
    
    private let ownerLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir Next", size: 15)
        label.textAlignment = .left
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let ownerImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFit
        image.clipsToBounds = true
        image.layer.cornerRadius = 25
        return image
    }()
    
    private let dateLabel: UILabel = {
       let label = UILabel()
        label.textColor = .gray
        label.font = UIFont(name: "Avenir Next", size: 12)
        label.textAlignment = .right
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.5
        return label
    }()
    
    private let postImage: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        return image
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubview(ownerLabel)
        addSubview(ownerImage)
        addSubview(dateLabel)
        addSubview(postImage)
        
        ownerImage.anchor(top: topAnchor,
                          left: leftAnchor,
                          bottom: nil,
                          right: nil,
                          paddingTop: 8,
                          paddingLeft: 8,
                          paddingBottom: 0,
                          paddingRight: 0,
                          width: 50,
                          height: 50,
                          enableInsets: false)
        
        ownerLabel.anchor(top: topAnchor,
                          left:ownerImage.rightAnchor,
                          bottom: nil,
                          right: dateLabel.leftAnchor,
                          paddingTop: 16,
                          paddingLeft: 6,
                          paddingBottom: 0,
                          paddingRight: 0,
                          width: 0,
                          height: 30,
                          enableInsets: false)
        
        dateLabel.anchor(top: topAnchor,
                         left: nil,
                         bottom: nil,
                         right: rightAnchor,
                         paddingTop: 16,
                         paddingLeft: 8,
                         paddingBottom: 0,
                         paddingRight: 8,
                         width: 100,
                         height: 30,
                         enableInsets: false)
        
        postImage.anchor(top: ownerImage.bottomAnchor,
                         left: leftAnchor,
                         bottom: bottomAnchor,
                         right: rightAnchor,
                         paddingTop: 6,
                         paddingLeft: 0,
                         paddingBottom: 8,
                         paddingRight: 0,
                         width: 0,
                         height: 0,
                         enableInsets: false)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: Configure Cell
    func configureCell(photo: Photo) {
        ownerLabel.text     = photo.ownername
        dateLabel.text      = photo.datetaken.stringToDate().timeAgoSinceDate()
        do {
            let ownerData       = try Data(contentsOf: URL(string: photo.getProfilePhoto())!)
            let postData        = try Data(contentsOf: URL(string: photo.getPhotoUrl())!)
            ownerImage.image    = UIImage(data: ownerData)
            postImage.image     = UIImage(data: postData)
        } catch {
            ownerImage.image    = #imageLiteral(resourceName: "profile")
        }
    }

}

