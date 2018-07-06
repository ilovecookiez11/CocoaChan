//
//  BoardPageTableViewController.swift
//  
//
//  Created by yelyah on 2/20/18.
//

import UIKit
import SwiftyJSON

class BoardPageTableViewController: UITableViewController {
    
    var currentBoard = "nothing"
    var posts = [Post]()
    var myJSON = JSON()
    var boardPage = 0
    let refresher = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentBoard)
        fetchJSON()
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        self.navigationItem.title = currentBoard + " - Page " + String(describing: boardPage)
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(NewThread))
        
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(reloadingData), for: .valueChanged)

        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.navigationItem.backBarButtonItem?.title = " "
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
    */
    

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let post = posts[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! PostCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        var replyPart, imagePart : String
        var threadClosed = ""
        var threadPinned = ""
        cell.postNumber = post.postNumber
        
        /*Comment is returned as an html formatted string, /p/ even comes with javascript on it
         Parsing HTML is not recommended on background threads (tableView's dataSource runs on a background thread)
         that's why I'm parsing it here*/
        let css = "<head><meta charset='utf-8'><style>html{font-size: 15 px;font-family:'Helvetica';}span.quote{color: green;}.quoteLink,.quotelink,.deadlink{color:#d00!important;text-decoration:underline}</style></head>"
        let myComment = css + post.comment
        let myCommentData : Data? = myComment.data(using: .utf8)
        let comment = try? NSAttributedString(data: myCommentData!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        cell.shortPost?.attributedText = comment
        
        
        //Determining image (if there is one)
        if((post.imageURL) != nil){
            let thumb = "https://i.4cdn.org" + currentBoard + String(describing:post.imageURL!) + "s.jpg"
            cell.BoardViewThumbnail?.downloadedFrom(link: thumb)
            cell.BoardViewThumbnail?.isHidden = false
        }
        else{
            print("this post has no image: " + String(describing: post.postNumber))
            
            cell.BoardViewThumbnail?.isHidden = true
            
        }
        
        //morePostInfo: Bottom text
        let date = Date(timeIntervalSince1970: Double(post.date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MMM/yy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        if(post.replyCount == 0) //morePostInfo conditionals
        {
            replyPart = "No replies"
        }
        else if(post.replyCount == 1)
        {
            replyPart = "1 reply"
        }
        else{
            replyPart = String(describing:post.replyCount) + " replies"
        }
        
        if(post.imageCount == 0)
        {
            imagePart = " and no images"
        }
        else if(post.imageCount == 1)
        {
            imagePart = " and 1 image"
        }
        else{
            imagePart = " and " + String(describing:post.imageCount) + " images"
        }
        
        if(post.title.count == 0)
        {
            cell.morePostInfo?.text = replyPart + imagePart + "."
        }
        else{
            let myTitle = post.title.htmlDecoded
            let attributedTitle = NSMutableAttributedString(string: myTitle, attributes:[NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
            let moreInfo = NSMutableAttributedString(string: replyPart + imagePart + ". ")
            let combination = NSMutableAttributedString()
            combination.append(moreInfo)
            combination.append(attributedTitle)
            cell.morePostInfo?.attributedText = combination
        }
        if(post.locked == 1){
            threadClosed = "🔒"
        }
        if(post.sticky == 1){
            threadPinned = "📌"
        }
        
        let myGreen = UIColor(red:0.07, green:0.47, blue:0.26, alpha:1.0)
        let myRight = NSMutableParagraphStyle()
        myRight.alignment = .right
        
        let myPostName = NSMutableAttributedString(string: post.name, attributes: [NSAttributedStringKey.foregroundColor: myGreen, NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 12)])
        let postInfo = NSMutableAttributedString(string: " " + strDate + " No." + String(describing:post.postNumber) + threadClosed + threadPinned, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 12), NSAttributedStringKey.paragraphStyle: myRight])
        let myPostInfo = NSMutableAttributedString()
        myPostInfo.append(myPostName)
        myPostInfo.append(postInfo)
        
        cell.postInfo?.attributedText = myPostInfo
        cell.shortPost?.font = UIFont.systemFont(ofSize: 14)
        cell.shortPost?.lineBreakMode = .byTruncatingTail
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BoardPageToThreadSegue"){
            let selectedRowIndex = self.tableView.indexPathForSelectedRow
            let myCell = self.tableView.cellForRow(at: selectedRowIndex!) as! PostCell
            let myCurrentBoard = self.currentBoard
            let myThread = myCell.postNumber
            let BoardPageToThreadVC:ThreadViewController = segue.destination as! ThreadViewController
            BoardPageToThreadVC.currentBoard = myCurrentBoard
            BoardPageToThreadVC.threadNumber = myThread!
            navigationItem.backBarButtonItem?.title = currentBoard
        }
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
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

    func fetchJSON() {
        let urlString = "https://a.4cdn.org" + currentBoard + "catalog.json"
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                myJSON = try! JSON(data: data)
                self.parse(json: myJSON)
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                return
                }
            }
    performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
    }
    
    @objc func reloadingData(){
        DispatchQueue.main.async {
            self.fetchJSON()
        }
        refresher.endRefreshing()
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        self.tableView.reloadData()
    }
    
    func parse(json: JSON) {
        posts.removeAll()
        for result in json[boardPage]["threads"].arrayValue {
            
            let name = result["name"].stringValue
            let title = result["sub"].stringValue
            
            
            let comment = result["com"].stringValue
            /*let css = "<head><meta charset='utf-8'><style>html{font-size: 15 px;font-family:'Helvetica';}span.quote{color: green;}</style></head>"
            myComment = css + myComment
            let myCommentData : Data? = myComment.data(using: .utf8)
            let comment = try? NSAttributedString(data: myCommentData!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)*/
            
            let time = result["time"].int //date is given as UNIX timestamp
            let imageURL : Int? = result["tim"].int//image URL is determined as UNIX milliseconds
            let threadNumber = result["no"].int
            let imageCount = result["images"].int
            let replyCount = result["replies"].int
            var sticky = result["sticky"].int
            var closed = result["closed"].int
            
            if sticky == nil{
                sticky = 0
            }
            if closed == nil{
                closed = 0
            }
            
            
            let obj = Post(postNumber: threadNumber!, title: title, name: name, comment: comment, date: time!, imageURL: imageURL, imageCount: imageCount!, replyCount: replyCount!, locked: closed!, sticky: sticky!)
            
            posts.append(obj)
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func NewThread() {
        
        let ac = UIAlertController(title: "Placeholder", message: "NewThread: Method not implemented yet.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func showError() {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        let ac = UIAlertController(title: "Loading error", message: "There was a problem downloading data from 4chan; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }

}
