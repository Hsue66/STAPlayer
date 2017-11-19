//
//  ViewController.swift
//  SimpleSTAPlayer
//
//  Created by Sumin Hong on 2017. 11. 7..
//  Copyright © 2017년 Sumin Hong. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {

    var vList = [URL] ()
    var vName = [String] ()
    //var allVids: PHFetchResult<PHAsset>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /**
            Find video file from PhotoLibrary
         */
        PHPhotoLibrary.requestAuthorization { (status) -> Void in
            let allVidOptions = PHFetchOptions()
            allVidOptions.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
            allVidOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            
            let allVids = PHAsset.fetchAssets(with: allVidOptions)
            
            for index in 0..<allVids.count {
                print(allVids[index])
                
                let options: PHVideoRequestOptions = PHVideoRequestOptions()
                options.version = .original
                
                PHImageManager.default().requestAVAsset(forVideo: allVids[index], options: options, resultHandler: { (asset, audioMix, info) in
                    if let urlAsset = asset as? AVURLAsset {
                        let localVideoUrl = urlAsset.url
                        
                        DispatchQueue.main.async {
                            //self.vList[index] = localVideoUrl
                            self.vList.append(localVideoUrl)
                            //print("COUNTddd -------- \(self.vList.count)")
                            
                            let urlstr = "\(localVideoUrl)"
                            let arrstr = urlstr.split(separator: "/")
                            self.vName.append("\(arrstr[arrstr.count-1])")
                        }
                    }
                })
            }
        }
        
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "loadVideo"{
            let videoNavController = segue.destination as! VideoNavigationController
            let videoTableController = videoNavController.viewControllers.first as! VideoTableViewController
            
            print("hhhhhhhhhhhh \(vList.count)")
            videoTableController.videoList = vList
            videoTableController.videoNames = vName
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}

