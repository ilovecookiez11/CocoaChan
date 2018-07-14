//
//  PostImageViewController.swift
//  CocoaChan
//
//  Created by yelyah on 7/13/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit

class PostImageViewController: UIViewController {

    @IBOutlet weak var theImageView: UIImageView!
    
    var currentImage = "none"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        theImageView.downloadedFrom(link: currentImage)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
