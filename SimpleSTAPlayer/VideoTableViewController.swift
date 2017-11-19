//
//  VideoTableViewController.swift
//  SimpleSTAPlayer
//
//  Created by Sumin Hong on 2017. 11. 7..
//  Copyright © 2017년 Sumin Hong. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VideoTableViewController: UITableViewController {

    var videoImages = [String] ()
    var videoNames = [String] ()
    //var videoN = [String] ()
    var videoList = [URL] ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //videoNames = ["race1","race2","game"]
        //videoImages = ["race1.png","race2.png","game.png"]
        
        for idx in 0..<videoList.count{
            print("VIDEO-------- \(videoList[idx])")
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showVideo"{
            let videoViewController = segue.destination as! VideoViewController
            
            let myIndexPath = self.tableView.indexPathForSelectedRow!
            let row = myIndexPath.row
            videoViewController.vtitle = videoNames[row]
            videoViewController.vUrl = videoList[row]
        }
        
        /*
         let myIndexPath = self.tableView.indexPathForSelectedRow!
         let row = myIndexPath.row
         
         let destination = segue.destination as! AVPlayerViewController
         let videoString: String? = Bundle.main.path(forResource: videoNames[row], ofType: ".mp4")
         
         if let url = videoString {
         let videoURL = NSURL(fileURLWithPath: url)
         destination.player = AVPlayer(url: videoURL as URL)
         }
         */
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
        // #warning Incomplete implementation, return the number of rows
        return videoNames.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableCell", for: indexPath) as! VideoTableViewCell
        
        let row = indexPath.row
        cell.VideoLabel.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
        cell.VideoLabel.text = videoNames[row]
       //cell.VideoImage.image = UIImage(named: videoImages[row])
        
        ///*
        var thumbImage: UIImage?
        let asset = AVAsset(url: videoList[row])
        let assetImgGenerate = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        let time = CMTimeMake(asset.duration.value / 3, asset.duration.timescale)
        if let CGImage = try? assetImgGenerate.copyCGImage(at: time, actualTime: nil) {
            thumbImage = UIImage(cgImage: CGImage)
        }
        cell.VideoImage.image = thumbImage
        //*/
        
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

}
