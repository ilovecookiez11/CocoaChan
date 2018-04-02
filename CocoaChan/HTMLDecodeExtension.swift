//
//  HTMLDecodeExtension.swift
//  CocoaChan
//
//  found this on pajeetoverflow, cleans up JSON
//  Created by yelyah on 2/11/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit

extension String {
    var htmlDecoded: String {
        let decoded = try? NSAttributedString(data: Data(utf8), options: [.documentType: NSAttributedString.DocumentType.html,            .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil).string
        
        return decoded ?? self
    }
}
