//
//  ThreadViewController.swift
//  CocoaChan
//
//  Created by yelyah on 3/19/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit

class ThreadViewController: UITableViewController {
    
    var currentBoard = "nothing"
    var threadNumber = 0
    var posts = [ThreadPost]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print(currentBoard, threadNumber)
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
        return posts.count
    }

   /* override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }*/

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
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
            
            let name = result["name"].stringValue
            let title = result["sub"].stringValue
            let comment = result["com"].stringValue
            let time = result["time"].int //date is given as UNIX timestamp
            var imageURL = result["tim"].int //image URL is determined as UNIX milliseconds
            let threadNumber = result["no"].int
            var myfilename = result["filename"].stringValue
            var myfileExt = result["ext"].stringValue
            
            if(imageURL == nil){
                imageURL = 0
            }
            
            //print(imageURL)
            
            let obj = ThreadPost(postNumber: threadNumber!, title: title, name: name, comment: comment, date: time!, imageURL: imageURL!, filename: myfilename, fileExt: myfileExt)
            
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
