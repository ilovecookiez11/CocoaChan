//
//  FirstViewController.swift
//  CocoaChan
//
//  Created by yelyah on 2/5/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit
import SwiftyJSON

class FirstViewController: UITableViewController {

    var boards = [Board]()
    let defaults = UserDefaults.standard
    var sfwBoards = ["3", "a", "adv", "an", "asp", "biz", "c", "cgl", "ck", "cm", "co", "diy", "fa", "fit", "g", "gd", "his", "int", "jp", "k", "lit", "lgbt", "m", "mlp", "mu", "news", "t", "o", "out", "p", "po", "qst", "sci", "sp", "tg", "toy", "trv", "tv", "v", "vg", "vip", "vp", "vr", "w", "wsg", "wsr", "x"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        navigationItem.title = "Boards"
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewBoard))
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor:UIColor(red:0.49, green:0.11, blue:0.09, alpha:1.0)];
        navigationController?.navigationBar.tintColor = UIColor(red:0.49, green:0.11, blue:0.09, alpha:1.0)
        navigationController?.navigationBar.barTintColor = UIColor(red:1.00, green:1.00, blue:0.94, alpha:1.0)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 140
        
        
        
        if let savedBoards = defaults.object(forKey: "boards") as? Data {
            boards = NSKeyedUnarchiver.unarchiveObject(with: savedBoards) as! [Board]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return boards.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let board = boards[indexPath.item]
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! BoardCell
        
        cell.title?.text = board.shortName + " - " + board.name
        cell.detail?.text = board.boardDescription
        cell.title?.font = UIFont.boldSystemFont(ofSize: cell.title.font.pointSize)
        
        cell.contentView.restorationIdentifier = board.shortName
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    //changes row position on TableView
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedObject = self.boards[sourceIndexPath.row]
        boards.remove(at: sourceIndexPath.row)
        boards.insert(movedObject, at: destinationIndexPath.row)
        saveBoardList()
        self.tableView.reloadData()
    }
    
    
    //removes rows from TableView
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    if editingStyle == .delete {
        self.boards.remove(at: indexPath.row)
        saveBoardList()
        self.tableView.reloadData()
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "BoardsToBoardPageSegue"){
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            let selectedRowIndex = self.tableView.indexPathForSelectedRow
            let myCell = self.tableView.cellForRow(at: selectedRowIndex!)
            let myCurrentBoard = myCell?.contentView.restorationIdentifier
            let BoardsToBoardPageVC:BoardPageTableViewController = segue.destination as! BoardPageTableViewController
            let backItem = UIBarButtonItem()
            backItem.title = " "
            BoardsToBoardPageVC.navigationItem.backBarButtonItem? = backItem
            BoardsToBoardPageVC.currentBoard = myCurrentBoard!
        }
    }
    
    
    @objc func addNewBoard(){ //"@objc" before a #selector function, thx Swift 4 :^)
        let boardnameAlert = UIAlertController(title: "Enter a new board:", message: nil, preferredStyle: .alert)
                boardnameAlert.addTextField()
                
                boardnameAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                
                boardnameAlert.addAction(UIAlertAction(title: "OK", style: .default) { [unowned self, boardnameAlert] _ in
                    
                    let newName = boardnameAlert.textFields![0]
                    self.confirmBoard(shortName: newName.text!)
                    
                })
                
                self.present(boardnameAlert, animated: true)
                
                
            }
    
    func confirmBoard(shortName: String){
        let myShortName = shortName.replacingOccurrences(of: "/", with: "")
        
        if let url = URL(string: "https://a.4cdn.org/boards.json") {
            if let data = try? Data(contentsOf: url) {
                let json = try! JSON(data: data)
                var foundBoard = false
                var repeatedBoard = false
                
                
                for board in json["boards"].arrayValue{
                    if board["board"].stringValue == myShortName{
                        foundBoard = true
                        print("Board found!")
                        let myName = board["title"].stringValue
                        var myBoardDescription = board["meta_description"].stringValue
                        myBoardDescription = myBoardDescription.htmlDecoded
                        let shortName1 = "/"+myShortName+"/"
                        
                        if let savedBoards = defaults.object(forKey: "boards") as? Data {
                            boards = NSKeyedUnarchiver.unarchiveObject(with: savedBoards) as! [Board]
                        }
                        
                        for board in boards {
                            if (board.shortName == shortName1)
                            {
                                repeatedBoard = true
                            }
                        }
                        
                        if (repeatedBoard == true){
                            print("Repeated board")
                            let alertView = UIAlertView(title: "Repeated board", message: "This board had been previously added.", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                            alertView.show()
                        }
                        else
                        {
                            let newBoard = Board(name: myName, shortName: shortName1, boardDescription: myBoardDescription)
                            boards.append(newBoard)
                            self.saveBoardList()
                            
                            var disclaimer = "Notice: This board is considered Not Safe for Work by 4chan. Adult content will not be filtered by default. Viewer discretion is advised."
                            
                            if (sfwBoards.contains(myShortName)){
                                disclaimer = "Notice: This board is considered Work Safe by 4chan. Posts are overseen by a staff of moderators and janitors so posting content that is not suitable for this environment (including adult content) may result in a ban."
                            }
                            
                            let alertView = UIAlertView(title: "Board added!", message: disclaimer, delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                            alertView.show()
                        }
                    }
                }
                if (foundBoard == false){
                    print("Board was never found")
                    let alertView = UIAlertView(title: "Couldn't find specified board", message: "Make sure to enter a valid 4chan board like /a/ or /tv/", delegate: self as? UIAlertViewDelegate, cancelButtonTitle: "OK")
                    alertView.show()
                }
                
                
            }
        //performSelector(onMainThread: #selector(showError), with: nil, waitUntilDone: false)
            
        tableView?.reloadData()
        }
    }
    
    
    func saveBoardList(){
        let savedData = NSKeyedArchiver.archivedData(withRootObject: boards)
        let defaults = UserDefaults.standard
        defaults.set(savedData, forKey: "boards")
    }
    
    @objc func showError() {
        let ac = UIAlertController(title: "Loading error", message: "Unable to connect to 4chan", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }


}
