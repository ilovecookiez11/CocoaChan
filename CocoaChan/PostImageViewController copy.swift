//
//  PostImageViewController.swift
//  CocoaChan
//
//  Created by yelyah on 7/13/18.
//  Copyright © 2018 yelyah. All rights reserved.
//

import Photos
import UIKit
import Alamofire
import AlamofireImage
import Kingfisher

class PostImageViewController: UIViewController {

    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var theImageView: UIImageView!
    var currentBoard = "none"
    var currentImage = "none"
    var fileType = "none"
    var picsURLArray = [String]()
    var imageIndex = 0
    var theFileURL = URL(string: "none")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let server = "https://i.4cdn.org"
        theFileURL = URL(string: server + currentBoard + picsURLArray[imageIndex])!
        fileType = theFileURL.pathExtension
        //let urlRequest = URLRequest(url: theFileURL)
        
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
                self.saveButton.isEnabled = true
            })
        case "gif":
            theImageView.kf.indicatorType = .activity
            theImageView.kf.setImage(with: theFileURL, placeholder: nil, options: nil, completionHandler: {
                (image, error, cacheType, imageUrl) in
                self.saveButton.isEnabled = true
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
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
        
        switch fileType{
        case "jpg", "jpeg", "png":
            UIImageWriteToSavedPhotosAlbum(self.theImageView.image!, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        case "gif":
            let gifData = try? Data(contentsOf:self.theFileURL)
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
        
            //var assetsLibrary = ALAssetsLibrary()
        default:
            break
        }
    }
    
    @IBAction func closedButtonTapped(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    

}
