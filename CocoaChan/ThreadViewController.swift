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
    var postForRow = [Int: Int]()
    var repliesForPost = [Int: [Int]]()
    var imageURLArray = [String]()
    var postImage = ""
    var postFileExt = ""
    let picsServer = "https://i.4cdn.org"
    let refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentBoard, threadNumber)
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
        fetchJSON()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        tableView.addSubview(refresher)
        refresher.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresher.addTarget(self, action: #selector(reloadData), for: .valueChanged)
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
        postForRow.updateValue(indexPath.item, forKey: post.postNumber)
        
        
        cell.postNumber = post.postNumber
        
        if((post.imageURL) != nil){
            let thumb = picsServer + currentBoard + String(describing:post.imageURL!) + "s.jpg"
            cell.myImageView?.downloadedFrom(link: thumb)
            cell.myImageView?.isHidden = false
            cell.myCustomViewLabel?.isHidden = false
            let myGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(self.TappedView(_sender:)))
            cell.myCustomView?.addGestureRecognizer(myGestureRecognizer)
            cell.myCustomView?.isUserInteractionEnabled = true
            
            cell.postImage = post.imageURL
            cell.postExtension = post.fileExt
            cell.postFilename = post.filename
            
            
            
            let imageSpace = UIBezierPath(rect: CGRect(x: 0, y: 0, width: 90, height: 100))
            cell.PostText?.textContainer.exclusionPaths = [imageSpace]
            let filesize = Int64(exactly: post.fileSize!)
            let sizeString = ByteCountFormatter.string(fromByteCount: filesize!, countStyle: ByteCountFormatter.CountStyle.binary)
            cell.myCustomViewLabel?.text = sizeString + " " + post.fileExt!
            
            
        }
            
        else{
            //print("this post has no image: " + String(describing: post.postNumber))
            cell.PostText?.textContainer.exclusionPaths = [UIBezierPath(rect: CGRect(x: 0, y: 0, width: 0, height: 0))]
            cell.myImageView?.isHidden = true
            cell.myCustomViewLabel?.isHidden = true
           
            
        }
        
        /*Comment is returned as an html formatted string, /p/ even comes with javascript on it
         Parsing HTML is not recommended on background threads (tableView's dataSource runs on a background thread)
         that's why I'm parsing it here*/
        //print(String(describing: post.postNumber) + " says: " + post.comment)
        
        cell.PostText?.attributedText = PrettyPost(postText: post.comment)
        cell.PostText?.font = UIFont.systemFont(ofSize: 14)
        
        
        let date = Date(timeIntervalSince1970: Double(post.date))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd/MMM/yy HH:mm" //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        
        let myGreen = UIColor(red:0.07, green:0.47, blue:0.26, alpha:1.0)
        let myPostName = NSMutableAttributedString(string: post.name, attributes: [NSAttributedString.Key.foregroundColor: myGreen, NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 12)])
        let postInfo = NSMutableAttributedString(string: " " + strDate + " No." + String(describing:post.postNumber), attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        let myPostInfo = NSMutableAttributedString()
        myPostInfo.append(myPostName)
        myPostInfo.append(postInfo)
        
        let replies = repliesForPost[post.postNumber]
        let noOfReplies = replies?.count
        
        if(noOfReplies != nil){
            cell.repliesButton?.setTitle("View " + String(describing: noOfReplies!) + " replies", for: UIControl.State.normal)
            cell.repliesButton?.isHidden = false
        }
        else {
            cell.repliesButton?.isHidden = true
        }
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
            let myPostNumber = result["no"].int!
            let myfilename = result["filename"].stringValue
            let myfileExt = result["ext"].stringValue
            let myfileSize = result["fsize"].int
            
            if(imgURL != nil){
                obj = ThreadPost(postNumber: myPostNumber, title: title, name: name, comment: comment, date: time!, imageURL: imgURL!, filename: myfilename, fileExt: myfileExt, fileSize: myfileSize)
                imageURLArray.append(picsServer + currentBoard + String(describing: imgURL!) + myfileExt)
                
            }
            else{
                obj = ThreadPost(postNumber: myPostNumber, title: title, name: name, comment: comment, date: time!, imageURL: nil, filename: myfilename, fileExt: myfileExt, fileSize: nil)
            }
            
            //print(imageURL)
            
            posts.append(obj)
            
            //Listing posts quoted on this post with RegEx
            let pattern = "(?<=<a href=\\\"#p)[0-9]+"
            let postNumbersString = comment.matchingStrings(regex: pattern)
            //let postsNumArray = postNumbersString.map {Int($0)!}
            
            for stringArray in postNumbersString {
                let repliedPost = Int(stringArray.first!)!
                print(myPostNumber, " replied to ", repliedPost)
                repliesForPost[repliedPost, default:[]].append(myPostNumber)
            }
            
            //print(postNumbersString)
            //repliesForPost.updateValue(postNumbersString, forKey: threadNumber!)
            
                
            
            
        }
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "ThreadToNavSegue"){
            
            let ThreadToNavController = segue.destination as? UINavigationController
            //let ThreadToPostImageVC:PostImageViewController = ThreadToNavController?.topViewController as! PostImageViewController
            let ThreadToCarouselVC:CarouselPageViewController = ThreadToNavController?.topViewController as! CarouselPageViewController
            ThreadToCarouselVC.currentBoard = currentBoard
            ThreadToCarouselVC.currentImage = postImage
            ThreadToCarouselVC.fileType = postFileExt
            ThreadToCarouselVC.picsURLArray = imageURLArray
            ThreadToCarouselVC.imageIndex = imageURLArray.index(of: postImage)!
            
        }
    }
    
    @objc func reloadData(){
        DispatchQueue.main.async {
            self.fetchJSON()
        }
        refresher.endRefreshing()
        tableView.performSelector(onMainThread: #selector(UITableView.reloadData), with: nil, waitUntilDone: false)
        postForRow.removeAll()
        repliesForPost.removeAll()
        imageURLArray.removeAll()
        self.tableView.reloadData()
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "There was a problem downloading data from 4chan; please check your connection and try again.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
    
    @objc func TappedView(_sender: UITapGestureRecognizer? = nil){
        //I can't believe this one works
        let cell = _sender?.view?.superview?.superview?.superview as! ThreadPostCell
        postImage = String(describing: cell.postImage!) + cell.postExtension
        //performSegue(withIdentifier: "ThreadToPostImageSegue", sender: self)
        if let pageViewController = self.storyboard?.instantiateViewController(withIdentifier: "NewNavController") as? UINavigationController{
            let ThreadToCarouselVC: CarouselPageViewController = pageViewController.topViewController as! CarouselPageViewController
            ThreadToCarouselVC.currentBoard = currentBoard
            ThreadToCarouselVC.currentImage = postImage
            ThreadToCarouselVC.fileType = postFileExt
            ThreadToCarouselVC.picsURLArray = imageURLArray
            ThreadToCarouselVC.imageIndex = imageURLArray.index(of: picsServer + currentBoard + postImage)!
            self.present(pageViewController, animated: true, completion: nil)
        }
        
    }
    
    func PrettyPost(postText: String) -> NSAttributedString{
        let css = "<head><meta charset='utf-8'><style>html{font-size: 15 px;font-family:'Helvetica';}span.quote{color: #789922;}.quoteLink,.quotelink,.deadlink{color:#d00!important;text-decoration:underline}</style></head>"
        let myComment = css + postText
        let myCommentData : Data? = myComment.data(using: .utf8)
        let comment = try? NSAttributedString(data: myCommentData!, options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil)
        return comment!
    }
    
    

}
