//
//  ViewController.swift
//  MusicPlay
//
//  Created by User on 5/17/17.
//  Copyright © 2017 User. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate {
    var mp3Player:Player?
    var timer:Timer?
    var programmaticVolumeChange = false
    let audioSession = AVAudioSession.sharedInstance()
    var mediapicker1: MPMediaPickerController!
    var tracksArray = [Any]()
    var songTitle = [String]()
    
    @IBOutlet weak var trackName: UILabel!
    @IBOutlet weak var trackTime: UILabel!
    @IBOutlet weak var progressBar: UIProgressView!
    @IBOutlet weak var volumeSlider: UISlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if MPMediaLibrary.authorizationStatus() == .authorized{
            getmediaQuery()
            setupNotificationCenter()
            setTrackName()
            updateViews()
        }else{
            displayMediaLibraryError()
        }

       
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
         listenVolumeButton()
    }
    func displayMediaLibraryError() {
        
        var error: String
        switch MPMediaLibrary.authorizationStatus() {
        case .restricted:
            error = "Media library access restricted by corporate or parental settings"
        case .denied:
            error = "Media library access denied by user"
        default:
            error = "Unknown error"
        }
        
        let controller = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        controller.addAction(UIAlertAction(title: "Open Settings", style: .default, handler: { (action) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            } else {
                // Fallback on earlier versions
            }
        }))
        present(controller, animated: true, completion: nil)
    }
    
   
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "outputVolume"{
            let change1 = change?[NSKeyValueChangeKey.newKey]
            volumeSlider.value = change1 as! Float
        }
    }
    
    func listenVolumeButton(){

        volumeSlider.value = audioSession.outputVolume
        
        do{
            try audioSession.setActive(true)
        }catch{
            
        }
        audioSession.addObserver(self, forKeyPath: "outputVolume",options: NSKeyValueObservingOptions.new, context: nil)
    }
    //MARK: Button Actions
    //play action
    @IBAction func playSong(sender: AnyObject) {
        mp3Player?.play()
        startTimer()
    }
    
    //Stop Action
    @IBAction func stopSong(sender: AnyObject) {
        mp3Player?.stop()
        updateViews()
        timer?.invalidate()
    }
    
    //pause Action
    @IBAction func pauseSong(sender: AnyObject) {
        mp3Player?.pause()
        timer?.invalidate()
    }
    
    //forward action
    @IBAction func playNextSong(sender: AnyObject) {
        mp3Player?.nextSong(songFinshedPlaying: false)
        startTimer()
    }
    
    // set volume Action
    @IBAction func setVolume(sender: UISlider) {
//        mp3Player?.setVolume(volume: sender.value)
        let volView = MPVolumeView()
        if let view = volView.subviews.first as? UISlider{
            view.value = sender.value
            mp3Player?.setVolume(volume: view.value)
            
        }
        
    }
    
    //rewind Action
    @IBAction func playPreviousSong(sender: AnyObject) {
        
        mp3Player?.previousSong()//startTimer()
    }

    //MARK: Functions
    //Function that will make timer start
    func startTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateViewsWithTimer(theTimer:)), userInfo: nil, repeats: true)
    }

    func updateViewsWithTimer(theTimer: Timer){
        updateViews()
    }
    
    //Track Time is updated with the current time property
    func updateViews(){
        trackTime.text = mp3Player?.getCurrentTimeAsString()
        if let progss = mp3Player?.getProgress(){

            DispatchQueue.main.async {
                self.progressBar.setProgress(progss , animated: true)
                self.progressBar.progress = progss
            }
            
        }
            }
    
    func setTrackName(){
        trackName.text = mp3Player?.getCurrentTrackName()
    }
    
    //MARK :Notification
    //Notification to track the name of song when song
    func setupNotificationCenter(){
        NotificationCenter.default.addObserver(self,
                                                         selector:#selector(ViewController.setTrackName),
                                                         name:NSNotification.Name(rawValue: "SetTrackNameText"),
                                                         object:nil)
    }

    @IBAction func pickSongs(_ sender: Any) {
        let mediaPicker = MPMediaPickerController(mediaTypes:.music)
        mediaPicker.allowsPickingMultipleItems = true
        mediapicker1 = mediaPicker
        mediapicker1.prompt = "Select a song that you like Play"
        mediaPicker.delegate = self
        self.present(mediaPicker, animated: true, completion: nil)
    
    }
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
      tracksArray = []
        songTitle = []
        for items in mediaItemCollection.items as [MPMediaItem]{
            if let url = items.value(forProperty: MPMediaItemPropertyAssetURL) as? NSURL {
                tracksArray.append(url)
            }
            if let songName = items.title{
                songTitle.append(songName)
            }
        }
        mp3Player = Player(tracksPlayerUrl: tracksArray, trackName: songTitle)
        self.dismiss(animated: true, completion: nil)
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController)
    {
    self.dismiss(animated: true, completion: nil)
    }
    
    //Get List of All Songs
    func getmediaQuery(){
        if let songsList: [MPMediaItem] = MPMediaQuery.songs().items{
            tracksArray = []
            songTitle = []
        for song in songsList{
            if let url = song.value(forProperty: MPMediaItemPropertyAssetURL) as! NSURL?{
                tracksArray.append(url)
            }
            if let songName = song.title{
                songTitle.append(songName)
            }
        }
        mp3Player = Player(tracksPlayerUrl: tracksArray, trackName: songTitle)
        return
        }
    }
    
    
    deinit {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")

    }


}

