//
//  Board.swift
//  
//
//  Created by yelyah on 2/5/18.
//

import Foundation

class Board : NSObject, NSCoding{
    var name : String
    var shortName : String
    var boardDescription : String
    //var archiveURL : String
    
    init(name : String, shortName : String, boardDescription : String) {
        self.name = name;
        self.shortName = shortName;
        self.boardDescription = boardDescription;
    }
    
    required init(coder aDecoder: NSCoder) {
        name = aDecoder.decodeObject(forKey: "name") as! String
        shortName = aDecoder.decodeObject(forKey: "shortName") as! String
        boardDescription = aDecoder.decodeObject(forKey: "boardDescription") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: "name")
        aCoder.encode(shortName, forKey: "shortName")
        aCoder.encode(boardDescription, forKey: "boardDescription")
    }
}
