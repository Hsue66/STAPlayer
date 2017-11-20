//
//  VideoViewController.swift
//  SimpleSTAPlayer
//
//  Created by Sumin Hong on 2017. 11. 12..
//  Copyright © 2017년 Sumin Hong. All rights reserved.
//

import UIKit
import AVFoundation

class VideoViewController: UIViewController {

    @IBOutlet weak var VideoView: UIView!
    @IBOutlet weak var VideoTitle: UINavigationItem!
    
    var player: AVPlayer!
    var playerLayer: AVPlayerLayer!
    
    var isPlaying = false
    var isBinaural = false
    var isRecording = false
    
    var fileURL: URL!
    var nowTime: Float64?
    var nowAngle: CGFloat = 0.0
    var nowElev: Float = 0
    
    var vtitle: String?
    var vUrl: URL!
    
    var recBtn: UIBarButtonItem!
    var onOffBtn: UIBarButtonItem!
    
    var joystick1 = JoyStickView()
    
    let controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(white: 0, alpha: 0)
        return view
    }()
    
    /* if you want to use onOffbutton as overlay button, find and remove [onOffButton] comment
    let onOffButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("On", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleBinural), for: .touchUpInside)
        return button
    }()
     */
    
    let playPressedButton: UIButton = {
        let button = UIButton(type: .system)
        let image = UIImage(named: "play")
        button.setImage(image, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .white
        //button.isHidden = true
        button.addTarget(self, action: #selector(handlePause), for: .touchUpInside)
        return button
    }()
    
    let videoDurationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    let currentTimeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .right
        return label
    }()
    
    // set elevation Slider
    let elevSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(UIImage(named: "circle"), for: .normal)
        slider.maximumTrackTintColor = .white
        slider.maximumValue = 90
        slider.minimumValue = 0
        slider.addTarget(self, action: #selector(handleElevation), for: .valueChanged)
        return slider
    }()
    
    let videoSlider: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.setThumbImage(UIImage(named: "circle"), for: .normal)
        slider.maximumTrackTintColor = .white
        slider.addTarget(self, action: #selector(handleSliderChange), for: .valueChanged)
        return slider
    }()
    
    //Erase After Check//////////////////////////////////////////////
    let magnitudeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    
    let thetaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "0.0"
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textAlignment = .left
        return label
    }()
    /////////////////////////////////////////////////////////////////////
    
    @objc func handleSliderChange(){
        if let duration = player.currentItem?.duration{
            let totalSeconds = CMTimeGetSeconds(duration)
            let seekTime = CMTime(value: Int64(Float64(videoSlider.value)*totalSeconds), timescale:1)
            player.seek(to: seekTime, completionHandler: {(completedSeek) in
            })
        }
        
    }
    
    // change nowElev value and record vlaue
    @objc func handleElevation(){
        var diff = false
        if nowElev == elevSlider.value{
            diff = true
        }
        nowElev = elevSlider.value
        
        if isRecording && !diff{
            self.writeValue()
        }
    }
    
    @objc func handlePause(){
        if isPlaying{
            player.pause()
            playPressedButton.setImage(UIImage(named: "play"), for: .normal)
            
            // automatic Binaural off
            joystick1.resetPosition()
            joystick1.onoff = false
            onOffBtn.title = "On"
            isBinaural = false
        }else{
            player.play()
            playPressedButton.setImage(UIImage(named: "pause"), for: .normal)
        }
        isPlaying = !isPlaying
    }
    
    @objc func handleBinaural(){
        if isPlaying {
            isBinaural = !isBinaural
        }
        
        if isBinaural{
            joystick1.onoff = true
            onOffBtn.title = "Off"
        }else{
            joystick1.resetPosition()
            joystick1.onoff = false
            onOffBtn.title = "On"
        }
    }
    
    @objc func handleRecording(){
        isRecording = !isRecording
        if isRecording{
            recBtn.tintColor = UIColor.red
        }else{
            recBtn.tintColor = UIColor.black
            
            var fileContents = ""
            do {
                fileContents = try String(contentsOf: fileURL)
            } catch let error as NSError {
                print("Error occured: \(fileURL), Error: " + error.localizedDescription)
            }
            print("Saved: \n\(fileContents)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        // set rightBarButtons
        recBtn = UIBarButtonItem(title: "REC", style: .plain, target: self, action: #selector(handleRecording))
        onOffBtn = UIBarButtonItem(title: "On", style: .plain, target: self, action: #selector(handleBinaural))
        navigationItem.rightBarButtonItems = [onOffBtn, recBtn]
        
        // make navigationBar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        
        /* if you want to show title of video, add navigation item at Main.storyboard
        if let TitleVal = vtitle{
            VideoTitle.title = TitleVal
        }
         */
        
        // generate recording file
        let fileName = vtitle
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        fileURL = DocumentDirURL.appendingPathComponent(fileName!).appendingPathExtension("txt")
        print("FilePath: \(fileURL.path)")
        
        let writeStr = "time: 0.0, angle: 0.0, elevation: 0.0\n"
        do {
            try writeStr.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
        } catch let error as NSError {
            print("Error occured : \(fileURL), Error: " + error.localizedDescription)
        }
        
        
        setPlayerView()
        
        //Erase After Check//////////////////////////////////////////////
        controlsContainerView.addSubview(magnitudeLabel)
        magnitudeLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor).isActive = true
        magnitudeLabel.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 30).isActive = true
        magnitudeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        magnitudeLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
        controlsContainerView.addSubview(thetaLabel)
        thetaLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor).isActive = true
        thetaLabel.topAnchor.constraint(equalTo: magnitudeLabel.bottomAnchor, constant: 4).isActive = true
        thetaLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        thetaLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //Erase After Check//////////////////////////////////////////////
        
        /* if you want to use onOffbutton as overlay button, find and remove [onOffButton] comment
        controlsContainerView.addSubview(onOffButton)
        onOffButton.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -8).isActive = true
        onOffButton.topAnchor.constraint(equalTo: controlsContainerView.topAnchor, constant: 10).isActive = true
        onOffButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        onOffButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        */
        
        controlsContainerView.addSubview(playPressedButton)
        playPressedButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor).isActive = true
        playPressedButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        playPressedButton.widthAnchor.constraint(equalToConstant: 50).isActive = true
        playPressedButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
      
        
        controlsContainerView.addSubview(videoDurationLabel)
        videoDurationLabel.rightAnchor.constraint(equalTo: controlsContainerView.rightAnchor, constant: -8).isActive = true
        videoDurationLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor,constant:-2).isActive = true
        videoDurationLabel.widthAnchor.constraint(equalToConstant: 55).isActive = true
        videoDurationLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
 
        
        controlsContainerView.addSubview(currentTimeLabel)
        currentTimeLabel.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor).isActive = true
        currentTimeLabel.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor,constant:-2).isActive = true
        currentTimeLabel.widthAnchor.constraint(equalToConstant: 55).isActive = true
        currentTimeLabel.heightAnchor.constraint(equalToConstant: 24).isActive = true
        
        
        controlsContainerView.addSubview(videoSlider)
        videoSlider.rightAnchor.constraint(equalTo: videoDurationLabel.leftAnchor).isActive = true
        videoSlider.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor).isActive = true
        videoSlider.leftAnchor.constraint(equalTo: currentTimeLabel.rightAnchor, constant: 4).isActive = true
        videoSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        controlsContainerView.addSubview(elevSlider)
        elevSlider.heightAnchor.constraint(equalToConstant: 30).isActive = true
        elevSlider.transform = CGAffineTransform(rotationAngle: CGFloat(-Double.pi / 2))
        elevSlider.widthAnchor.constraint(equalToConstant: view.frame.height - 140 ).isActive = true
        elevSlider.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor).isActive = true
        elevSlider.leftAnchor.constraint(equalTo: controlsContainerView.leftAnchor, constant: -100).isActive = true
    
        VideoView.addSubview(controlsContainerView)
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        if (self.isMovingFromParentViewController || self.isBeingDismissed) {
            //백버튼 눌림
            if isPlaying{
                handlePause()
            }
        }
    }
    
    @objc private func writeValue(){
        let saveInfo =   "time: \(nowTime!), angle: \(nowAngle), elevation: \(nowElev)\n"

        do {
            let fileHandle = try FileHandle(forWritingTo: fileURL)
            fileHandle.seekToEndOfFile()
            fileHandle.write(saveInfo.data(using: .utf8)!)
            fileHandle.closeFile()
        } catch {
            print("Error occured : \(error)")
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(animated)
        
        // Create 'fixed' joystick
        //
        let rect = view.frame
        let size = CGSize(width: 140.0, height: 140.0)
        
        let joystick1Frame = CGRect(origin: CGPoint(x: (rect.width - size.width - 15.0), y:(rect.height-size.height-25.0)),size: size)
        joystick1 = JoyStickView(frame: joystick1Frame)
        joystick1.monitor = { angle, displacement in
            self.thetaLabel.text = "\(angle)"
            self.magnitudeLabel.text = "\(displacement)"
            self.nowAngle = angle
            if self.isRecording{
                self.writeValue()
            }
        }
        
        controlsContainerView.addSubview(joystick1)
        
        if isBinaural{
            joystick1.onoff = true
        }
        else{
            joystick1.onoff = false
        }
        joystick1.movable = false
        joystick1.alpha = 1.0
        joystick1.baseAlpha = 0.5 // let the background bleed thru the base
        joystick1.handleTintColor = UIColor.blue // Colorize the handle
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func setPlayerView(){
        
        /*
        let videoString: String? = Bundle.main.path(forResource: vtitle, ofType: ".mp4")
        
        if let url = videoString {
            let videoURL = NSURL(fileURLWithPath: url)
            player = AVPlayer(url: videoURL as URL)
        }*/
        
        player = AVPlayer(url: vUrl)
        
        player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new,.initial], context: nil)
        let interval = CMTime(value:1, timescale:1)
        player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main , using: {(progressTime) in
            self.currentTimeLabel.text = self.getTimeString(from: progressTime)
            
            if let duration = self.player.currentItem?.duration{
                let durationSeconds = CMTimeGetSeconds(duration)
                let seconds = CMTimeGetSeconds(progressTime)
                self.nowTime = seconds
                self.videoSlider.value = Float(seconds / durationSeconds)
                //print("\(self.nowTime)")
            }
        })
        
        playerLayer = AVPlayerLayer(player: player)
        playerLayer.videoGravity = .resize
        
        VideoView.layer.addSublayer(playerLayer)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer.frame = VideoView.bounds
        controlsContainerView.frame = VideoView.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "duration", let duration = player.currentItem?.duration.seconds, duration > 0.0 {
            videoDurationLabel.text = getTimeString(from: player.currentItem!.duration)
        }
        
    }
    
    func getTimeString(from time: CMTime) -> String {
        let totalSeconds = CMTimeGetSeconds(time)
        let hours = Int(totalSeconds/3600)
        let minutes = Int(totalSeconds/60) % 60
        let seconds = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if hours > 0 {
            return String(format: "%i:%02i:%02i", arguments: [hours,minutes,seconds])
        }else {
            return String(format: "%02i:%02i", arguments: [minutes,seconds])
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
