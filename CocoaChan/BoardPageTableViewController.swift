//
//  BoardPageTableViewController.swift
//  
//
//  Created by yelyah on 2/20/18.
//

import UIKit

class BoardPageTableViewController: UITableViewController {
    
    var currentBoard = "nothing"
    var posts = [Post]()
    var boardPage = 0
    let refresher = UIRefreshControl()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentBoard)
        fetchJSON()
        
        
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(reloadingData), for: .valueChanged)

        
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
        
        var replyPart = " "
        var imagePart = " "
        var threadClosed = ""
        var threadPinned = ""
        if((post.imageURL) != nil){
            let thumb = "https://i.4cdn.org" + currentBoard + String(describing:post.imageURL!) + "s.jpg"
            cell.BoardViewThumbnail?.downloadedFrom(link: thumb)
        }
        else{
            print("this post has no image")
            cell.BoardViewThumbnail?.image = nil
            cell.BoardViewThumbnail?.frame = CGRect(x: 0, y: 0, width: 0, height: 75)
            
        }
        cell.shortPost?.text = post.comment.htmlDecoded
        cell.postNumber = post.postNumber
        
        let date = Date(timeIntervalSince1970: Double(post.date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT") //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MMM/yy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        let myPostInfo = post.name + " " + strDate + " No." + String(describing:post.postNumber)
        
        if(post.replyCount == 0) //morePostInfo conditionals
        {
            replyPart = "No replies "
        }
        else if(post.replyCount == 1)
        {
            replyPart = "1 reply "
        }
        else{
            replyPart = String(describing:post.replyCount) + " replies "
        }
        
        if(post.imageCount == 0)
        {
            imagePart = "and no images"
        }
        else if(post.imageCount == 1)
        {
            imagePart = "and 1 image"
        }
        else{
            imagePart = "and " + String(describing:post.imageCount) + " images"
        }
        
        if(post.title.count == 0)
        {
            cell.morePostInfo?.text = replyPart + imagePart + "."
        }
        else{
            cell.morePostInfo?.text = replyPart + imagePart + ". "  + post.title.htmlDecoded
        }
        if(post.locked == 1){
            threadClosed = "🔒"
        }
        if(post.sticky == 1){
            threadPinned = "📌"
        }
        
        
        cell.postInfo?.text = myPostInfo + threadClosed + threadPinned
        //cell.morePostInfo?.text = post.title + ", " + replyPart + imagePart
        
        cell.postInfo?.font = UIFont.boldSystemFont(ofSize: cell.postInfo.font.pointSize)
        
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BoardPageToThreadSegue"){
            let selectedRowIndex = self.tableView.indexPathForSelectedRow
            let myCell = self.tableView.cellForRow(at: selectedRowIndex!) as! PostCell
            let myCurrentBoard = self.currentBoard
            let myThread = myCell.postNumber
            var BoardPageToThreadVC:ThreadViewController = segue.destination as! ThreadViewController
            BoardPageToThreadVC.currentBoard = myCurrentBoard
            BoardPageToThreadVC.threadNumber = myThread!
        }
    }

/*
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 40
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return UITableViewAutomaticDimension
        } else {
            return 40
        }
    }
*/
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
        
        if let url = URL(string: urlString) {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                self.parse(json: json)
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
            let time = result["time"].int //date is given as UNIX timestamp
            var imageURL : Int? = result["tim"].int//image URL is determined as UNIX milliseconds
            let threadNumber = result["no"].int
            let imageCount = result["images"].int
            let replyCount = result["replies"].int
            var sticky = result["sticky"].int
            var closed = result["closed"].int
            
            /*if(imageURL == nil){
                imageURL = 0
            }*/
            if sticky == nil{
                sticky = 0
            }
            if closed == nil{
                closed = 0
            }
            
            //print(imageURL)
            
            let obj = Post(postNumber: threadNumber!, title: title, name: name, comment: comment, date: time!, imageURL: imageURL, imageCount: imageCount!, replyCount: replyCount!, locked: closed!, sticky: sticky!)
            
            posts.append(obj)
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem downloading data from 4chan; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    func attributedString(from string: String, nonBoldRange: NSRange?) -> NSAttributedString {
        let fontSize = UIFont.systemFontSize
        let attrs = [
            NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: fontSize),
            NSAttributedStringKey.foregroundColor: UIColor.black
        ]
        let nonBoldAttribute = [
            NSAttributedStringKey.font: UIFont.systemFont(ofSize: fontSize),
            ]
        let attrStr = NSMutableAttributedString(string: string, attributes: attrs)
        if let range = nonBoldRange {
            attrStr.setAttributes(nonBoldAttribute, range: range)
        }
        return attrStr
    }

}
