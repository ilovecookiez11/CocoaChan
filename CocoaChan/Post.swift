//
//  Post.swift
//  CocoaChan
//
//  Created by yelyah on 3/4/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import Foundation

class Post : NSObject{
    var title : String
    var name : String
    var comment : String
    var date : intmax_t
    var imageURL : Int?
    var imageCount : intmax_t
    var replyCount : intmax_t
    var postNumber : intmax_t
    var locked : intmax_t
    var sticky: intmax_t
    
    init(postNumber: intmax_t, title: String, name: String, comment: String, date: intmax_t, imageURL: Int?, imageCount: intmax_t, replyCount: intmax_t, locked: intmax_t, sticky: intmax_t) {
        self.postNumber = postNumber
        self.title = title
        self.name = name
        self.comment = comment
        self.date = date
        self.imageURL = imageURL
        self.imageCount = imageCount
        self.replyCount = replyCount
        self.locked = locked
        self.sticky = sticky
    }
    
}

class ThreadPost : NSObject{
    var title : String
    var name : String
    var comment : String
    var date : intmax_t
    var imageURL : Int?
    var postNumber : intmax_t
    var filename : String?
    var fileExt : String?
    
    init(postNumber: intmax_t, title: String, name: String, comment: String, date: intmax_t, imageURL: intmax_t, filename: String, fileExt : String) {
        self.postNumber = postNumber
        self.title = title
        self.name = name
        self.comment = comment
        self.date = date
        self.imageURL = imageURL
        self.filename = filename
        self.fileExt = fileExt
        


    }
    
}

