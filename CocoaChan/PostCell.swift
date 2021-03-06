//
//  BoardCell.swift
//  CocoaChan
//
//  Created by yelyah on 2/11/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class PostCell: UITableViewCell {

    @IBOutlet weak var postInfo: UILabel!
    @IBOutlet weak var shortPost: UILabel!
    @IBOutlet weak var BoardViewThumbnail: UIImageView!
    @IBOutlet weak var morePostInfo: UILabel!
    
    @IBOutlet weak var PostText: UITextView!
    @IBOutlet weak var imageButton: UIButton!
    var postNumber: Int!

    
}

class ThreadPostCell : UITableViewCell {
    
    @IBOutlet weak var PostText: UITextView!
    @IBOutlet weak var myCustomView: UIView!
    @IBOutlet weak var myImageView: UIImageView!
    @IBOutlet weak var myCustomViewLabel: UILabel!
    @IBOutlet weak var postInfo: UILabel!
    @IBOutlet weak var myDumbConstraint: NSLayoutConstraint!
    @IBOutlet weak var myStackView: UIStackView!
    @IBOutlet weak var repliesButton: UIButton!
    
    var postNumber: Int!
    var postImage: Int!
    var postExtension: String!
    var postFilename: String!
}
