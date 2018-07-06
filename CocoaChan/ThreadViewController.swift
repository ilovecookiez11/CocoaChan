//
//  ThreadViewController.swift
//  CocoaChan
//
//  Created by yelyah on 3/19/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit
import SwiftyJSON

class ThreadViewController: UITableViewController {
    
    var currentBoard = "nothing"
    var threadNumber = 0
    var posts = [ThreadPost]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentBoard, threadNumber)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        fetchJSON()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

   

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ThreadPostCell
        
        cell.postNumber = post.postNumber
        
        if((post.imageURL) != nil){
            let thumb = "https://i.4cdn.org" + currentBoard + String(describing:post.imageURL!) + "s.jpg"
            cell.myImageView?.downloadedFrom(link: thumb)
            cell.myCustomView?.isHidden = false
            
            let imageSpace = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 90, height: 100))
            cell.PostText?.textContainer.exclusionPaths = [imageSpace]
            let filesize = Int64(exactly: post.fileSize!)
            let sizeString = ByteCountFormatter.string(fromByteCount: filesize!, countStyle: ByteCountFormatter.CountStyle.binary)
            cell.myCustomViewLabel?.text = sizeString + " " + post.fileExt!
            
        }
            
        else{
            print("this post has no image: " + String(describing: post.postNumber))
            //cell.myDumbConstraint?.isActive = false
            cell.PostText?.textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))]
            cell.myCustomView?.isHidden = true
            cell.myCustomView?.frame = CGRect(x:0, y: 0, width:0, height:0)
            
            
        }
        
        /*Comment is returned as an html formatted string, /p/ even comes with javascript on it
         Parsing HTML is not recommended on background threads (tableView's dataSource runs on a background thread)
         that's why I'm parsing it here*/
        let css = "<head><meta charset='utf-8'><style>html{font-size: 15 px;font-family:'Helvetica';}span.quote{color: green;}.quoteLink,.quotelink,.deadlink{color:#d00!important;text-decoration:underline}</style></head>"
        let myComment = css + post.comment
        let myCommentData : Data? = myComment.data(using: .utf8)
        let comment = try? NSAttributedString(data: myCommentData!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        cell.PostText?.attributedText = comment
        cell.PostText?.font = UIFont.systemFont(ofSize: 14)
        
        
        let date = Date(timeIntervalSince1970: Double(post.date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MMM/yy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        let myGreen = UIColor(red:0.07, green:0.47, blue:0.26, alpha:1.0)
        let myPostName = NSMutableAttributedString(string: post.name, attributes: [NSAttributedStringKey.foregroundColor: myGreen, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
        let postInfo = NSMutableAttributedString(string: " " + strDate + " No." + String(describing:post.postNumber), attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12)])
        let myPostInfo = NSMutableAttributedString()
        myPostInfo.append(myPostName)
        myPostInfo.append(postInfo)
        
        cell.postInfo?.attributedText = myPostInfo
        
        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func fetchJSON() {
        let urlString = "https://a.4cdn.org" + currentBoard + "/thread/" + String(describing:threadNumber) + ".json"
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parse(json: json)
                return
            }
        }
        performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    func parse(json: JSON) {
        posts.removeAll()
        for result in json["posts"].arrayValue {
            var imgURL : Int?
            var obj : ThreadPost
            
            let name = result["name"].stringValue
            let title = result["sub"].stringValue
            let comment = result["com"].stringValue
            let time = result["time"].int //date is given as UNIX timestamp
            imgURL = result["tim"].int //image URL is determined as UNIX milliseconds
            let threadNumber = result["no"].int
            let myfilename = result["filename"].stringValue
            let myfileExt = result["ext"].stringValue
            let myfileSize = result["fsize"].int
            
            if(imgURL != nil){
                obj = ThreadPost(postNumber: threadNumber!, title: title, name: name, comment: comment, date: time!, imageURL: imgURL!, filename: myfilename, fileExt: myfileExt, fileSize: myfileSize)
            }
            else{
                obj = ThreadPost(postNumber: threadNumber!, title: title, name: name, comment: comment, date: time!, imageURL: nil, filename: myfilename, fileExt: myfileExt, fileSize: nil)
            }
            
            //print(imageURL)
            
            posts.append(obj)
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem downloading data from 4chan; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    

}
