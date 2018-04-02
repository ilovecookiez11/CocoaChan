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
    
    var postNumber: Int!

    
}
