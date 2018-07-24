//
//  CarouselPageViewController.swift
//  CocoaChan
//
//  Created by yelyah on 7/19/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import UIKit
import Kingfisher
import Photos

class CarouselPageViewController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var currentBoard = "none"
    var currentImage = "none"
    var fileType = "none"
    var picsURLArray = [String]()
    var imageIndex = 0
    var theFileURL = URL(string: "")
    var currentPage = 0 {
        didSet{
            //let img = (self.viewControllers![0] as! CarouselImageViewController).theFileURL.absoluteString
            navigationItem.title = (String(describing: currentPage + 1)) + "/" + String(describing:picsURLArray.count)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        self.dataSource = self
        NotificationsSetup()
        theFileURL = URL(string: picsURLArray[imageIndex])
        //print("Carousel got this index: " + String(describing:imageIndex))
        //let myImageVC = CarouselImageViewController(anURL: theFileURL!)
        let myImageVC = self.storyboard?.instantiateViewController(withIdentifier: "AnImageViewController") as! CarouselImageViewController
        myImageVC.theFileURL = theFileURL!
        myImageVC.index = imageIndex
        currentPage = imageIndex
        self.setViewControllers([myImageVC], direction: .forward, animated: false, completion: nil)
        print(self.viewControllers?.enumerated() as Any)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let img = (viewController as! CarouselImageViewController).theFileURL
        let localIndex = picsURLArray.index(of: img.absoluteString)! + 1
        if localIndex >= picsURLArray.count{
            return nil
        }
        
        let myURL = URL(string:picsURLArray[localIndex])!
        //print("Previous page: " + myURL.absoluteString)
        let myImageVC = self.storyboard?.instantiateViewController(withIdentifier: "AnImageViewController") as! CarouselImageViewController
        myImageVC.theFileURL = myURL
        myImageVC.index = localIndex
        imageIndex = localIndex
        return myImageVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let img = (viewController as! CarouselImageViewController).theFileURL
        let localIndex = picsURLArray.index(of: img.absoluteString)! - 1
        if localIndex < 0{
            return nil
        }
        
        let myURL = URL(string:picsURLArray[localIndex])!
        //print("Next page: " + myURL.absoluteString)
        let myImageVC = self.storyboard?.instantiateViewController(withIdentifier: "AnImageViewController") as! CarouselImageViewController
        myImageVC.theFileURL = myURL
        myImageVC.index = localIndex
        imageIndex = localIndex
        return myImageVC
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            let vc = self.viewControllers?.first as? CarouselImageViewController
            print(pageViewController.childViewControllers.description)
            print("transition completed")
            currentPage = picsURLArray.index(of: (vc?.theFileURL.absoluteString)!)!
            print("new index = " + String(describing: picsURLArray.index(of: (vc?.theFileURL.absoluteString)!)))
            if (vc?.shouldEnableSave)!{
                EnableSave()
            }
            else{
                DisableSave()
            }

        }
        return
        }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func image(_ image: UIImage, didFinishSavingWithError error: NSError?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            
            let ac = UIAlertController(title: "Saved!", message: "The image has been saved to your photo library.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }
    
    @objc func EnableSave() {
        self.saveButton.isEnabled = true
    }
    
    @objc func DisableSave() {
        self.saveButton.isEnabled = false
    }
    
    @IBAction func closedButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        let vc = self.viewControllers?.first as? CarouselImageViewController
        fileType = (vc?.theFileURL.pathExtension)!
        
        switch fileType{
        case "jpg", "jpeg", "png":
            UIImageWriteToSavedPhotosAlbum((vc?.theImageView.image!)!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        case "gif":
            let gifData = try? Data(contentsOf:(vc?.theFileURL)!)
            PHPhotoLibrary.shared().performChanges({
                PHAssetCreationRequest.forAsset().addResource(with: .photo, data: gifData!, options: nil)
            }) { success, error in
                guard success else {
                    let ac = UIAlertController(title: "Save error", message: error?.localizedDescription, preferredStyle: .alert)
                    ac.addAction(UIAlertAction(title: "OK", style: .default))
                    self.present(ac, animated: true)
                    return
                }
                let ac = UIAlertController(title: "Saved!", message: "This gif has been saved to your photo library.", preferredStyle: .alert)
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
            
        default:
            break
        }
    }
    
    func NotificationsSetup(){
        let enableSaveNotification = NSNotification.Name(rawValue: "shouldEnableSave")
        NotificationCenter.default.addObserver(self, selector: #selector(EnableSave), name: enableSaveNotification, object: nil)
        let disableSaveNotification = NSNotification.Name(rawValue: "shouldDisableSave")
        NotificationCenter.default.addObserver(self, selector: #selector(DisableSave), name: disableSaveNotification, object: nil)
    }

}

class CarouselImageViewController : UIViewController{
    
    
    @IBOutlet weak var theScrollView: UIScrollView!
    @IBOutlet weak var theImageView: UIImageView!
    var theFileURL : URL
    var index = 0
    var shouldEnableSave = false;
    let enableSaveNotification = NSNotification.Name(rawValue: "shouldEnableSave")
    let disableSaveNotification = NSNotification.Name(rawValue: "shouldDisableSave")
    
    
    override func viewDidLoad() {
        
        print("Current Image: " + theFileURL.absoluteString + " for index: " + String(describing:index))
        //NotificationCenter.default.post(name: disableSaveNotification, object: nil)
        
        let fileType = theFileURL.pathExtension
        switch fileType {
        case "jpeg", "jpg", "png":
            theImageView.kf.indicatorType = .activity
            theImageView.kf.setImage(with: theFileURL, placeholder: nil, options: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                // image: Image? `nil` means failed
                // error: NSError? non-`nil` means failed
                // cacheType: CacheType
                //                  .none - Just downloaded
                //                  .memory - Got from memory cache
                //                  .disk - Got from disk cache
                // imageUrl: URL of the image
                //print("image downloaded: \(self.theImageView.image)")
                //self.saveButton.isEnabled = true
                NotificationCenter.default.post(name: self.enableSaveNotification, object: nil)
                self.shouldEnableSave = true
                print("Save button should be enabled by now")
            })
        case "gif":
            theImageView.kf.indicatorType = .activity
            theImageView.kf.setImage(with: theFileURL, placeholder: nil, options: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                self.shouldEnableSave = true
                NotificationCenter.default.post(name: self.enableSaveNotification, object: nil)
            })
        case "webm":
            var webmURL = theFileURL.absoluteString
            print(webmURL)
            let myFileURL : NSString = webmURL as NSString
            let y = myFileURL.deletingPathExtension
            webmURL = y + "s.jpg"
            print("Final:" + webmURL)
            theImageView.downloadedFrom(link: webmURL)
        default:
            break
        }
        
    }
    
    
    required init?(coder decoder: NSCoder) {
        self.theFileURL = URL(string: "none")!
        super.init(coder: decoder)
    }
    
}
